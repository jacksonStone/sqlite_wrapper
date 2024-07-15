package main

import (
	"database/sql"
	"embed"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"

	_ "github.com/mattn/go-sqlite3"
)

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
	defaultDb := db
	// Execute each file as an SQL statement
	for _, file := range files {
		if filepath.Ext(file.Name()) == ".sql" {
			func() {
				// Check if the migration has already been executed
				var name string
				err := defaultDb.QueryRow(fmt.Sprintf("SELECT name FROM %s WHERE name = ?", migration_table), file.Name()).Scan(&name)
				if err == nil {
					fmt.Printf("Migration %s has already been executed, skipping...\n", file.Name())
					return
				}
				filePath := filepath.Join(directory, file.Name())
				sqlContent, err := migrations.ReadFile(filePath)
				if err != nil {
					log.Printf("Error reading file %s: %v", file.Name(), err)
					return
				}
				content := string(sqlContent)
				var targetDb *sql.DB
				if strings.Contains(content, "-- DATABASE") {
					dbName := strings.Split(strings.Split(content, "\n")[0], "-- DATABASE ")[1]
					targetDb, err = sql.Open("sqlite3", "./"+dbName+".db")
					if err != nil {
						log.Fatal(err)
					}
					defer targetDb.Close()
				} else {
					targetDb = defaultDb
				}
				_, err = targetDb.Exec(content)
				if err != nil {
					log.Printf("Error executing %s: %v", file.Name(), err)
					return
				}

				fmt.Printf("Executed %s successfully\n", file.Name())

				// Persist that the migration has been executed
				_, err = defaultDb.Exec(fmt.Sprintf("INSERT INTO %s (name) VALUES (?)", migration_table), file.Name())
				if err != nil {
					log.Printf("Error inserting migration %s into %s: %v", file.Name(), migration_table, err)
				}
			}()

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
