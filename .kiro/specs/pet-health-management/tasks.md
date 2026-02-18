# Implementation Plan: Pet Health Management System

## Overview

This implementation plan breaks down the Pet Health Management System into incremental, testable steps. The approach follows Rails conventions, starting with database migrations and models, then building up services and controllers, and finally adding visualization features. Each major component includes property-based tests to validate correctness properties from the design document.

## Tasks

- [x] 1. Set up testing infrastructure and dependencies
  - Add rantly gem for property-based testing to Gemfile
  - Add factory_bot_rails gem for test data generation
  - Configure test helper with property testing support
  - Create base test generators for common data types (dates, weights, names)
  - _Requirements: All (testing foundation)_

- [x] 2. Create database migrations for health tracking
  - [x] 2.1 Create health_records migration
    - Add table with pet_id, medication_id, weight (decimal 5,2), recorded_on (not null), mood, activity_level, food_intake, medication_name, medication_dose, status, notes, timestamps
    - Add foreign key constraints and indexes
    - _Requirements: 1.1, 1.2, 1.3, 1.6_
  
  - [x] 2.2 Create medications migration
    - Add table with pet_id, medication_name (not null), dose (not null), start_date (not null), end_date, notes, timestamps
    - Add foreign key constraints and indexes
    - _Requirements: 3.1, 3.4_
  
  - [x] 2.3 Create reminders migration
    - Add table with pet_id, reminder_type (not null), scheduled_date (not null), title (not null), description, completed_at, status (default: 'pending'), alert_context (text), timestamps
    - Add foreign key constraints and indexes
    - _Requirements: 9.1, 9.6_
  
  - [x] 2.4 Run migrations and verify schema
    - Execute rails db:migrate
    - Verify schema.rb reflects all new tables and constraints
    - _Requirements: 11.5_

- [x] 3. Create database migrations for veterinary management
  - [x] 3.1 Create vet_offices migration
    - Add table with name (not null), timestamps
    - _Requirements: 6.1_
  
  - [x] 3.2 Create addresses migration
    - Add table with vet_office_id (not null), city (not null), state (not null), zipcode (not null), country (not null), timestamps
    - Add foreign key constraint and index
    - _Requirements: 7.1, 7.4_
  
  - [x] 3.3 Create contacts migration
    - Add table with vet_office_id (not null), contact_type (not null), contact_value (not null), is_primary (boolean, default: false), timestamps
    - Add foreign key constraint and indexes
    - _Requirements: 8.1_
  
  - [x] 3.4 Create veterinarians migration
    - Add table with vet_office_id (not null), name (not null), work_history (text), years_of_experience (integer), timestamps
    - Add foreign key constraint and index
    - _Requirements: 4.1, 4.3_
  
  - [x] 3.5 Create ratings migration
    - Add table with veterinarian_id (not null), user_id (not null), rating_value (integer, not null), review_text (text), timestamps
    - Add foreign key constraints and unique index on [user_id, veterinarian_id]
    - _Requirements: 5.1, 5.4_
  
  - [x] 3.6 Run migrations and verify schema
    - Execute rails db:migrate
    - Verify all veterinary tables and relationships
    - _Requirements: 11.5_

- [x] 4. Implement HealthRecord model with validations
  - [x] 4.1 Create HealthRecord model
    - Add belongs_to :pet association
    - Add belongs_to :medication, optional: true association
    - Add validations for recorded_on (presence), weight (numericality, allow_nil), status (inclusion)
    - Add scopes: chronological, recent, with_weight
    - _Requirements: 1.2, 1.3, 1.6, 3.5_
  
  - [x] 4.2 Write property test for weight precision (Property 1)
    - **Property 1: Weight precision preservation**
    - **Validates: Requirements 1.1**
  
  - [x] 4.3 Write property test for required date validation (Property 2)
    - **Property 2: Required date validation**
    - **Validates: Requirements 1.2**
  
  - [x] 4.4 Write property test for optional fields (Property 3)
    - **Property 3: Optional fields acceptance**
    - **Validates: Requirements 1.3**
  
  - [x] 4.5 Write property test for chronological ordering (Property 4)
    - **Property 4: Chronological ordering**
    - **Validates: Requirements 1.4**
  
  - [x] 4.6 Write property test for date immutability (Property 5)
    - **Property 5: Recorded date immutability**
    - **Validates: Requirements 1.5**
  
  - [x] 4.7 Write property test for pet association (Property 6)
    - **Property 6: Pet association requirement**
    - **Validates: Requirements 1.6**

- [ ] 5. Implement Medication model with validations
  - [x] 5.1 Create Medication model
    - Add belongs_to :pet association
    - Add has_many :health_records association
    - Add validations for medication_name, dose, start_date (presence)
    - Add scopes: active, inactive
    - Add active? instance method
    - _Requirements: 3.1, 3.4, 3.5_
  
  - [x] 5.2 Write property test for medication required fields (Property 12)
    - **Property 12: Medication required fields**
    - **Validates: Requirements 3.1**
  
  - [x] 5.3 Write property test for active medication filtering (Property 13)
    - **Property 13: Active medication filtering**
    - **Validates: Requirements 3.2**
  
  - [x] 5.4 Write property test for medication status calculation (Property 14)
    - **Property 14: Medication status calculation**
    - **Validates: Requirements 3.3**
  
  - [x] 5.5 Write property test for medication-pet association (Property 15)
    - **Property 15: Medication-pet association**
    - **Validates: Requirements 3.4**

- [ ] 6. Implement veterinary office models
  - [x] 6.1 Create VetOffice model
    - Add has_one :address, dependent: :destroy association
    - Add has_many :contacts, dependent: :destroy association
    - Add has_many :veterinarians, dependent: :nullify association
    - Add validation for name (presence)
    - Add accepts_nested_attributes_for :address and :contacts
    - Add primary_phone and primary_email methods
    - _Requirements: 6.1, 6.2, 6.3_
  
  - [x] 6.2 Create Address model
    - Add belongs_to :vet_office association
    - Add validations for city, state, zipcode, country (presence)
    - Add conditional zipcode format validation for US
    - Add formatted instance method
    - _Requirements: 7.1, 7.2, 7.3, 7.4_
  
  - [x] 6.3 Create Contact model
    - Add belongs_to :vet_office association
    - Add validations for contact_type (inclusion), contact_value (presence)
    - Add conditional format validations for email and phone
    - Add before_save callback: ensure_single_primary_per_type
    - _Requirements: 8.1, 8.3, 8.5_
  
  - [x] 6.4 Write property tests for vet office models (Properties 26-28, 31-34, 35, 37-39)
    - Test vet office required fields, associations, and one-to-one relationships
    - Test address required fields, validation, and formatting
    - Test contact required fields, validation, and primary uniqueness
    - **Validates: Requirements 6.1, 6.2, 6.3, 7.1, 7.2, 7.3, 7.4, 8.1, 8.3, 8.5**

- [ ] 7. Implement veterinarian and rating models
  - [x] 7.1 Create Veterinarian model
    - Add belongs_to :vet_office association
    - Add has_many :ratings, dependent: :restrict_with_error association
    - Add validation for name (presence)
    - Add validation for years_of_experience (numericality, allow_nil)
    - Add average_rating and total_ratings methods
    - _Requirements: 4.1, 4.2, 4.3, 11.4_
  
  - [x] 7.2 Create Rating model
    - Add belongs_to :veterinarian association
    - Add belongs_to :user association
    - Add validation for rating_value (inclusion: 1..5)
    - Add uniqueness validation on user_id scoped to veterinarian_id
    - Add after_save and after_destroy callbacks to update veterinarian cache
    - _Requirements: 5.1, 5.3, 5.4_
  
  - [x] 7.3 Write property tests for veterinarian and rating models (Properties 17-25)
    - Test veterinarian required fields, associations, and office changes
    - Test rating constraints, uniqueness, and average calculation
    - **Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3, 5.4, 5.5**

- [ ] 8. Implement Reminder model with validations
  - [x] 8.1 Create Reminder model
    - Add belongs_to :pet association
    - Add validations for reminder_type (inclusion), scheduled_date (presence), title (presence)
    - Add scopes: upcoming, due, completed
    - Add due? instance method
    - Add complete! instance method
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_
  
  - [x] 8.2 Write property tests for reminder model (Properties 40-45)
    - Test reminder required fields, validation, status detection, and grouping
    - **Validates: Requirements 9.1, 9.2, 9.3, 9.4, 9.5, 9.6**

- [x] 9. Checkpoint - Ensure all model tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 10. Implement HealthAlertService
  - [x] 10.1 Create HealthAlertService class
    - Add initialize method accepting health_record
    - Add check_and_alert public method
    - Add private methods: check_weight_threshold, check_activity_level, check_declining_trends
    - Add private method: weight_threshold_for_species
    - Add private method: consistently_declining?
    - Add private method: create_alert_notification
    - Include error handling with logging
    - _Requirements: 2.1, 2.2, 2.5_
  
  - [x] 10.2 Add after_create callback to HealthRecord
    - Call HealthAlertService.new(self).check_and_alert
    - _Requirements: 2.1, 2.2, 2.5_
  
  - [x] 10.3 Write property tests for health alert service (Properties 7-9)
    - Test low weight alert generation
    - Test low activity alert generation
    - Test declining trend detection
    - **Validates: Requirements 2.1, 2.2, 2.5**

- [ ] 11. Implement VisualizationService
  - [x] 11.1 Create VisualizationService class
    - Add initialize method accepting pet, start_date, end_date
    - Add weight_chart_data method returning chart.js compatible data
    - Add medication_timeline_data method returning timeline data
    - Add health_metrics_data method returning aggregated metrics
    - Add private method: aggregate_by_category
    - _Requirements: 12.1, 12.2, 12.3, 12.5_
  
  - [x] 11.2 Write property tests for visualization service (Properties 54-57)
    - Test weight chart data structure
    - Test medication timeline data structure
    - Test date filtering
    - Test multi-metric visualization
    - **Validates: Requirements 12.1, 12.2, 12.3, 12.5**

- [ ] 12. Implement ReminderService
  - [x] 12.1 Create ReminderService class
    - Add class method: create_from_health_alert(pet, alert_context)
    - Add class method: mark_due_reminders
    - _Requirements: 10.1, 10.2, 9.2_
  
  - [x] 12.2 Write property tests for reminder service (Property 46)
    - Test alert context transfer to reminders
    - **Validates: Requirements 10.2**

- [ ] 13. Implement HealthRecordsController
  - [x] 13.1 Create HealthRecordsController with CRUD actions
    - Add before_action :set_pet
    - Add before_action :set_health_record for show, edit, update, destroy
    - Implement index action with pagination and visualization data
    - Implement create action with HealthAlertService integration
    - Implement update, destroy actions
    - Add private method: health_record_params
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_
  
  - [x] 13.2 Add routes for health records
    - Add nested routes under pets: resources :health_records
    - _Requirements: 1.1_

- [ ] 14. Implement MedicationsController
  - [x] 14.1 Create MedicationsController with CRUD actions
    - Add before_action :set_pet
    - Add before_action :set_medication for show, edit, update, destroy
    - Implement index action with active/inactive filtering
    - Implement create, update, destroy actions
    - Add private method: medication_params
    - _Requirements: 3.1, 3.2, 3.3_
  
  - [x] 14.2 Add routes for medications
    - Add nested routes under pets: resources :medications
    - _Requirements: 3.1_

- [ ] 15. Implement VetOfficesController
  - [x] 15.1 Create VetOfficesController with CRUD actions
    - Implement index action with location filtering
    - Implement show action displaying address, contacts, and veterinarians
    - Implement create action with nested attributes for address and contacts
    - Implement update, destroy actions
    - Add private method: vet_office_params (permit nested attributes)
    - _Requirements: 6.1, 6.2, 6.5_
  
  - [x] 15.2 Add routes for vet offices
    - Add resources :vet_offices
    - _Requirements: 6.1_

- [ ] 16. Implement VeterinariansController
  - [x] 16.1 Create VeterinariansController with CRUD actions
    - Implement index and show actions displaying ratings
    - Implement create, update, destroy actions
    - Add private method: veterinarian_params
    - _Requirements: 4.1, 4.2, 4.4_
  
  - [x] 16.2 Add routes for veterinarians
    - Add resources :veterinarians
    - _Requirements: 4.1_

- [ ] 17. Implement RatingsController
  - [x] 17.1 Create RatingsController with create and update actions
    - Add before_action :set_veterinarian
    - Implement create action with uniqueness handling
    - Implement update action for existing ratings
    - Add private method: rating_params
    - _Requirements: 5.1, 5.4, 5.5_
  
  - [x] 17.2 Add routes for ratings
    - Add nested routes under veterinarians: resources :ratings, only: [:create, :update]
    - _Requirements: 5.1_

- [ ] 18. Implement RemindersController
  - [x] 18.1 Create RemindersController with CRUD actions
    - Add before_action :set_pet
    - Add before_action :set_reminder for show, edit, update, destroy
    - Implement index action with upcoming/due/completed filtering
    - Implement create action
    - Implement complete action (custom route)
    - Add private method: reminder_params
    - _Requirements: 9.1, 9.3, 9.5_
  
  - [x] 18.2 Add routes for reminders
    - Add nested routes under pets: resources :reminders
    - Add member route: post :complete
    - _Requirements: 9.1_

- [x] 19. Checkpoint - Ensure all controller tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 20. Create views for health records
  - [x] 20.1 Create health records index view
    - Display health records table with pagination
    - Include weight chart visualization using Chart.js
    - Add link to create new health record
    - _Requirements: 1.4, 12.1_
  
  - [x] 20.2 Create health records form partial
    - Include fields for all health record attributes
    - Add medication dropdown (optional association)
    - Include date picker for recorded_on
    - _Requirements: 1.1, 1.2, 1.3_
  
  - [x] 20.3 Create health records show view
    - Display all health record details
    - Show associated medication if present
    - Include edit and delete links
    - _Requirements: 1.1, 1.2, 1.3_

- [ ] 21. Create views for medications
  - [x] 21.1 Create medications index view
    - Display active medications section
    - Display inactive medications section
    - Include medication timeline visualization
    - Add link to create new medication
    - _Requirements: 3.2, 12.2_
  
  - [x] 21.2 Create medications form partial
    - Include fields for medication_name, dose, start_date, end_date, notes
    - Add date pickers for dates
    - _Requirements: 3.1_

- [ ] 22. Create views for vet offices and veterinarians
  - [x] 22.1 Create vet offices index view
    - Display vet offices with location filtering
    - Show address and primary contacts for each office
    - Add link to create new vet office
    - _Requirements: 6.2, 6.5_
  
  - [x] 22.2 Create vet office form with nested attributes
    - Include fields for office name
    - Include nested form for address (city, state, zipcode, country)
    - Include nested form for contacts (type, value, is_primary)
    - _Requirements: 6.1, 7.1, 8.1_
  
  - [x] 22.3 Create veterinarians show view
    - Display veterinarian details
    - Show average rating and total ratings
    - Display all reviews
    - Include rating form for current user
    - _Requirements: 4.2, 5.2_

- [ ] 23. Create views for reminders
  - [x] 23.1 Create reminders index view
    - Display upcoming reminders section
    - Display due reminders section (highlighted)
    - Display completed reminders section
    - Add link to create new reminder
    - _Requirements: 9.5_
  
  - [x] 23.2 Create reminder form partial
    - Include fields for reminder_type, scheduled_date, title, description
    - Add date picker for scheduled_date
    - Add dropdown for reminder_type
    - _Requirements: 9.1, 9.4_

- [ ] 24. Add JavaScript for visualizations
  - [ ] 24.1 Install Chart.js via importmap or npm
    - Add Chart.js to asset pipeline
    - _Requirements: 12.1_
  
  - [ ] 24.2 Create weight chart JavaScript
    - Fetch visualization data from controller
    - Render line chart for weight over time
    - Add date range filtering controls
    - _Requirements: 12.1, 12.3_
  
  - [ ] 24.3 Create medication timeline JavaScript
    - Fetch timeline data from controller
    - Render timeline visualization
    - Show medication periods and dosages
    - _Requirements: 12.2_
  
  - [ ] 24.4 Create health metrics charts
    - Render charts for mood, activity level, food intake
    - Use appropriate chart types (bar, pie)
    - _Requirements: 12.5_

- [ ] 25. Implement data integrity and cascade deletion
  - [x] 25.1 Update Pet model with cascade deletions
    - Add has_many :health_records, dependent: :destroy
    - Add has_many :medications, dependent: :destroy
    - Add has_many :reminders, dependent: :destroy
    - _Requirements: 11.1_
  
  - [x] 25.2 Update User model with cascade deletions
    - Verify has_many :pets, dependent: :destroy exists
    - _Requirements: 11.2_
  
  - [x] 25.3 Write property tests for cascade deletions (Properties 48-50)
    - Test pet deletion cascade
    - Test user deletion cascade
    - Test vet office deletion cascade
    - **Validates: Requirements 11.1, 11.2, 11.3**
  
  - [x] 25.4 Write property test for veterinarian deletion restriction (Property 51)
    - **Property 51: Veterinarian deletion restriction**
    - **Validates: Requirements 11.4**

- [ ] 26. Implement historical data export
  - [ ] 26.1 Add export action to HealthRecordsController
    - Implement export method generating PDF or CSV
    - Include date range filtering
    - Format data for printing
    - _Requirements: 13.4_
  
  - [ ] 26.2 Add export action to MedicationsController
    - Implement export method for medication history
    - Include duration and dosage information
    - _Requirements: 13.3_
  
  - [ ] 26.3 Add export buttons to views
    - Add export links to health records index
    - Add export links to medications index
    - _Requirements: 12.6, 13.4_

- [ ] 27. Add custom threshold configuration
  - [ ] 27.1 Create pet_health_thresholds table migration
    - Add table with pet_id, threshold_type, threshold_value, timestamps
    - Add foreign key constraint
    - _Requirements: 2.4_
  
  - [ ] 27.2 Create PetHealthThreshold model
    - Add belongs_to :pet association
    - Add validations for threshold_type and threshold_value
    - _Requirements: 2.4_
  
  - [ ] 27.3 Update HealthAlertService to use custom thresholds
    - Check for custom thresholds before using defaults
    - _Requirements: 2.4_
  
  - [ ] 27.4 Write property tests for custom thresholds (Properties 10, 47)
    - Test threshold persistence and retrieval
    - Test alert sensitivity configuration
    - **Validates: Requirements 2.4, 10.4**

- [ ] 28. Implement alert dismissal functionality
  - [ ] 28.1 Create dismissed_alerts table migration
    - Add table with pet_id, alert_type, alert_condition, dismissed_at, timestamps
    - Add foreign key constraint
    - _Requirements: 10.3_
  
  - [ ] 28.2 Create DismissedAlert model
    - Add belongs_to :pet association
    - Add validations
    - _Requirements: 10.3_
  
  - [ ] 28.3 Update HealthAlertService to check dismissed alerts
    - Skip alert generation for dismissed conditions
    - _Requirements: 10.3_
  
  - [ ] 28.4 Write property test for alert dismissal (Property 11)
    - **Property 11: Alert dismissal prevents repetition**
    - **Validates: Requirements 10.3**

- [x] 29. Final checkpoint - Run full test suite
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 30. Integration and final wiring
  - [ ] 30.1 Add navigation links to main layout
    - Add links to health records, medications, vet offices, reminders
    - _Requirements: All_
  
  - [ ] 30.2 Add dashboard view for pet health overview
    - Display recent health records
    - Show upcoming reminders
    - Display active medications
    - Include quick links to all features
    - _Requirements: All_
  
  - [ ] 30.3 Verify all routes and associations
    - Test navigation between all pages
    - Verify all links work correctly
    - _Requirements: All_

## Notes

- Tasks marked with `*` are optional property-based tests and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- Property tests validate universal correctness properties from the design document
- Unit tests should be added alongside property tests for edge cases and error conditions
- The implementation follows Rails conventions with RESTful routes and standard CRUD patterns
- Visualization features use Chart.js for client-side rendering
- All models include proper validations and associations as specified in the design
