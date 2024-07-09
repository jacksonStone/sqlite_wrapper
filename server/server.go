package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	_ "github.com/mattn/go-sqlite3"
)

type RequestBody struct {
	Query      string          `json:"query"`
	Parameters json.RawMessage `json:"parameters"`
}

func main() {
	// Open SQLite database
	path := "./database.db"
	if _, err := os.Stat(path); os.IsNotExist(err) {
		path = "../migrator/database.db"
	}
	db, err := sql.Open("sqlite3", path)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

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
