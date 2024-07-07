package main

import (
	"database/sql"
	"embed"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"sort"

	_ "github.com/mattn/go-sqlite3"
)

type RequestBody struct {
	Query      string          `json:"query"`
	Parameters json.RawMessage `json:"parameters"`
}

//go:embed migrations
var migrations embed.FS

func main() {
	// Open SQLite database
	db, err := sql.Open("sqlite3", "./database.db")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// Directory containing SQL files
	directory := "migrations"
	migration_table := "completed_migrations"
	run_migrations(directory, migration_table, db)

	http.HandleFunc("/execute", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Only POST method is allowed", http.StatusMethodNotAllowed)
			return
		}

		var data RequestBody
		err := json.NewDecoder(r.Body).Decode(&data)
		if err != nil {
			http.Error(w, "Error decoding JSON: "+err.Error(), http.StatusBadRequest)
			return
		}
		// Define a variable to hold the unmarshaled data
		var parameters []interface{}

		// Unmarshal the JSON data
		err = json.Unmarshal([]byte(data.Parameters), &parameters)
		if err != nil {
			log.Fatalf("Error unmarshaling JSON: %v", err)
		}

		if data.Query == "" {
			http.Error(w, "Query field is required", http.StatusBadRequest)
			return
		}

		_, err = db.Exec(data.Query, parameters...)
		if err != nil {
			print("Error executing query: " + err.Error())
			http.Error(w, "Error executing query: "+err.Error(), http.StatusBadRequest)
			return
		}
	})

	http.HandleFunc("/query", (func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Only POST method is allowed", http.StatusMethodNotAllowed)
			return
		}

		var data RequestBody
		err := json.NewDecoder(r.Body).Decode(&data)
		if err != nil {
			http.Error(w, "Error decoding JSON: "+err.Error(), http.StatusBadRequest)
			return
		}
		// Define a variable to hold the unmarshaled data
		var parameters []interface{}

		// Unmarshal the JSON data
		err = json.Unmarshal([]byte(data.Parameters), &parameters)
		if err != nil {
			http.Error(w, "invalid parameters provided: "+err.Error(), http.StatusBadRequest)
		}

		if data.Query == "" {
			http.Error(w, "Query field is required", http.StatusBadRequest)
			return
		}

		rows, err := db.Query(data.Query, parameters...)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return

		}
		columns, err := rows.Columns()
		if err != nil {
			http.Error(w, fmt.Sprintf("Failed to get columns: %v", err), http.StatusInternalServerError)
			return
		}

		var results []map[string]interface{}

		for rows.Next() {
			columnsData := make([]interface{}, len(columns))
			columnsPointers := make([]interface{}, len(columns))

			for i := range columnsData {
				columnsPointers[i] = &columnsData[i]
			}

			if err := rows.Scan(columnsPointers...); err != nil {
				http.Error(w, fmt.Sprintf("Failed to scan row: %v", err), http.StatusInternalServerError)
				return
			}

			rowMap := make(map[string]interface{})
			for i, colName := range columns {
				rowMap[colName] = columnsData[i]
			}

			results = append(results, rowMap)
		}

		if err := rows.Err(); err != nil {
			http.Error(w, fmt.Sprintf("Rows iteration error: %v", err), http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		if len(results) == 0 {
			// Prefer an empty array over null
			json.NewEncoder(w).Encode(make([]string, 0))
		} else {
			json.NewEncoder(w).Encode(results)
		}
	}))
	// For local development, just use http
	log.Println("Starting server on :3333")
	err = http.ListenAndServe(":3333", nil)
	if err != nil {
		log.Fatalf("ListenAndServe error: %v", err)
	}
}

func run_migrations(directory string, migration_table string, db *sql.DB) {
	// Create the migration table if it does not exist
	_, err := db.Exec(fmt.Sprintf(
		`CREATE TABLE IF NOT EXISTS %s (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT NOT NULL,
			created_at DATETIME DEFAULT CURRENT_TIMESTAMP
		);`, migration_table))
	if err != nil {
		log.Fatal(err)
	}
	// Get all files in the directory
	// Check if the directory exists
	if _, err := os.Stat(directory); os.IsNotExist(err) {
		log.Fatalf("Directory %s does not exist", directory)
	}

	// Read all files in the directory
	// read from embed.FS
	files, err := migrations.ReadDir(directory)
	if err != nil {
		log.Fatal(err)
	}

	// Sort files by name in ascending order
	sort.Slice(files, func(i, j int) bool {
		return files[i].Name() < files[j].Name()
	})

	// Execute each file as an SQL statement
	for _, file := range files {
		if filepath.Ext(file.Name()) == ".sql" {
			// Check if the migration has already been executed
			var name string
			err := db.QueryRow(fmt.Sprintf("SELECT name FROM %s WHERE name = ?", migration_table), file.Name()).Scan(&name)
			if err == nil {
				fmt.Printf("Migration %s has already been executed, skipping...\n", file.Name())
				continue
			}
			filePath := filepath.Join(directory, file.Name())
			sqlContent, err := os.ReadFile(filePath)
			if err != nil {
				log.Printf("Error reading file %s: %v", file.Name(), err)
				continue
			}

			_, err = db.Exec(string(sqlContent))
			if err != nil {
				log.Printf("Error executing %s: %v", file.Name(), err)
				continue
			}

			fmt.Printf("Executed %s successfully\n", file.Name())

			// Persist that the migration has been executed
			_, err = db.Exec(fmt.Sprintf("INSERT INTO %s (name) VALUES (?)", migration_table), file.Name())
			if err != nil {
				log.Printf("Error inserting migration %s into %s: %v", file.Name(), migration_table, err)
			}
		}
	}

	// Check if tables were created successfully
	rows, err := db.Query("SELECT name FROM sqlite_master WHERE type='table'")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	fmt.Println("Tables in the database:")
	for rows.Next() {
		var name string
		if err := rows.Scan(&name); err != nil {
			log.Fatal(err)
		}
		fmt.Println(name)
	}
}
