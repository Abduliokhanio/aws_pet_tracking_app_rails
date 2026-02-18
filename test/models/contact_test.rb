require "test_helper"

class ContactTest < ActiveSupport::TestCase
  # Property 35: Contact required fields
  # Validates: Requirements 8.1
  # For any contact creation attempt, the contact should be rejected if contact_type
  # or contact_value is missing, and accepted when both are present.
  test "property: contact required fields" do
    vet_office = vet_offices(:one)
    
    Rantly(20) do
      # Generate random valid values
      contact_type = choose("phone", "email")
      contact_value = if contact_type == "phone"
        "#{range(1000000000, 9999999999)}"
      else
        "test#{range(1, 9999)}@example.com"
      end
      
      # Test 1: Contact WITHOUT contact_type should be rejected
      contact_without_type = Contact.new(
        vet_office: vet_office,
        contact_value: contact_value
      )
      guard !contact_without_type.valid?
      guard contact_without_type.errors[:contact_type].present?
      
      # Test 2: Contact WITHOUT contact_value should be rejected
      contact_without_value = Contact.new(
        vet_office: vet_office,
        contact_type: contact_type
      )
      guard !contact_without_value.valid?
      guard contact_without_value.errors[:contact_value].present?
      
      # Test 3: Contact WITH both contact_type and contact_value should be accepted
      contact_with_both = Contact.new(
        vet_office: vet_office,
        contact_type: contact_type,
        contact_value: contact_value
      )
      guard contact_with_both.valid?
      guard contact_with_both.save
      
      # Verify the contact persists correctly
      retrieved = Contact.find(contact_with_both.id)
      guard retrieved.contact_type == contact_type
      guard retrieved.contact_value == contact_value
      
      # Clean up
      contact_with_both.destroy
    end
  end

  # Property 37: Contact type validation
  # Validates: Requirements 8.3
  # For any contact, if contact_type is 'email', contact_value should be rejected
  # if not a valid email format; if contact_type is 'phone', contact_value should
  # be rejected if not a valid phone format.
  test "property: contact type validation" do
    vet_office = vet_offices(:one)
    
    Rantly(20) do
      # Test 1: Email contacts with valid email format should be accepted
      valid_email = "user#{range(1, 9999)}@example.com"
      email_contact_valid = Contact.new(
        vet_office: vet_office,
        contact_type: "email",
        contact_value: valid_email
      )
      guard email_contact_valid.valid?
      guard email_contact_valid.save
      
      # Test 2: Email contacts with invalid email format should be rejected
      invalid_email = choose(
        "notanemail",
        "missing@domain",
        "@nodomain.com",
        "no-at-sign.com",
        "spaces in@email.com",
        "double@@domain.com"
      )
      email_contact_invalid = Contact.new(
        vet_office: vet_office,
        contact_type: "email",
        contact_value: invalid_email
      )
      guard !email_contact_invalid.valid?
      guard email_contact_invalid.errors[:contact_value].present?
      
      # Test 3: Phone contacts with valid phone format should be accepted
      # Valid format: 10-15 digits
      valid_phone = "#{range(1000000000, 9999999999999)}"
      phone_contact_valid = Contact.new(
        vet_office: vet_office,
        contact_type: "phone",
        contact_value: valid_phone
      )
      guard phone_contact_valid.valid?
      guard phone_contact_valid.save
      
      # Test 4: Phone contacts with invalid phone format should be rejected
      invalid_phone = choose(
        "123",           # Too short
        "12345678901234567890",  # Too long
        "123-456-7890",  # Contains dashes
        "(555) 123-4567", # Contains parentheses and spaces
        "abcdefghij",    # Contains letters
        "555.123.4567"   # Contains dots
      )
      phone_contact_invalid = Contact.new(
        vet_office: vet_office,
        contact_type: "phone",
        contact_value: invalid_phone
      )
      guard !phone_contact_invalid.valid?
      guard phone_contact_invalid.errors[:contact_value].present?
      
      # Clean up
      email_contact_valid.destroy
      phone_contact_valid.destroy
    end
  end

  # Property 38: Multiple contacts per office
  # Validates: Requirements 8.4
  # For any vet office, creating multiple contacts with different contact_type
  # or contact_value should succeed.
  test "property: multiple contacts per office" do
    vet_office = vet_offices(:one)
    
    Rantly(20) do
      # Generate a random number of contacts (2 to 6)
      num_contacts = range(2, 6)
      created_contacts = []
      
      num_contacts.times do |i|
        contact_type = choose("phone", "email")
        
        # Generate unique contact values
        contact_value = if contact_type == "phone"
          # Generate unique phone numbers
          base = 1000000000 + (i * 111111111)
          "#{base + range(0, 111111110)}"
        else
          # Generate unique emails
          "contact#{i}_#{range(1000, 9999)}@example.com"
        end
        
        contact = Contact.create!(
          vet_office: vet_office,
          contact_type: contact_type,
          contact_value: contact_value,
          is_primary: false
        )
        
        created_contacts << contact
      end
      
      # Verify all contacts were created successfully
      guard created_contacts.size == num_contacts
      
      # Verify all contacts are associated with the vet office
      office_contacts = vet_office.contacts.where(id: created_contacts.map(&:id))
      guard office_contacts.count == num_contacts
      
      # Verify each contact has unique values
      contact_values = created_contacts.map(&:contact_value)
      guard contact_values.uniq.size == contact_values.size
      
      # Verify we can query and retrieve all contacts
      created_contacts.each do |contact|
        retrieved = Contact.find(contact.id)
        guard retrieved.vet_office_id == vet_office.id
        guard retrieved.contact_type.present?
        guard retrieved.contact_value.present?
      end
      
      # Clean up
      created_contacts.each(&:destroy)
    end
  end

  # Property 39: Single primary per type per office
  # Validates: Requirements 8.5
  # For any vet office and contact_type, marking a contact as primary should
  # automatically unmark any other contact of the same type as primary for that office.
  test "property: single primary per type per office" do
    vet_office = vet_offices(:one)
    
    Rantly(20) do
      # Choose a contact type to test
      contact_type = choose("phone", "email")
      
      # Create multiple contacts of the same type
      num_contacts = range(2, 4)
      contacts = []
      
      num_contacts.times do |i|
        contact_value = if contact_type == "phone"
          "#{1000000000 + (i * 111111111) + range(0, 111111110)}"
        else
          "contact#{i}_#{range(1000, 9999)}@example.com"
        end
        
        contacts << Contact.create!(
          vet_office: vet_office,
          contact_type: contact_type,
          contact_value: contact_value,
          is_primary: false
        )
      end
      
      # Test 1: Mark the first contact as primary
      first_contact = contacts.first
      first_contact.update!(is_primary: true)
      
      # Verify only the first contact is primary
      first_contact.reload
      guard first_contact.is_primary == true
      
      # Verify no other contacts of the same type are primary
      other_contacts = contacts[1..-1]
      other_contacts.each do |contact|
        contact.reload
        guard contact.is_primary == false
      end
      
      # Test 2: Mark a different contact as primary
      second_contact = contacts[1]
      second_contact.update!(is_primary: true)
      
      # Verify only the second contact is primary now
      second_contact.reload
      guard second_contact.is_primary == true
      
      # Verify the first contact is no longer primary
      first_contact.reload
      guard first_contact.is_primary == false
      
      # Verify all other contacts are not primary
      contacts.each_with_index do |contact, idx|
        contact.reload
        if idx == 1
          guard contact.is_primary == true
        else
          guard contact.is_primary == false
        end
      end
      
      # Test 3: Verify only one primary per type per office
      primary_contacts = Contact.where(
        vet_office: vet_office,
        contact_type: contact_type,
        is_primary: true
      )
      guard primary_contacts.count == 1
      guard primary_contacts.first.id == second_contact.id
      
      # Test 4: Verify that contacts of different types can both be primary
      if contact_type == "phone"
        other_type = "email"
        other_value = "primary#{range(1000, 9999)}@example.com"
      else
        other_type = "phone"
        other_value = "#{range(1000000000, 9999999999)}"
      end
      
      other_type_contact = Contact.create!(
        vet_office: vet_office,
        contact_type: other_type,
        contact_value: other_value,
        is_primary: true
      )
      
      # Both should be primary (different types)
      second_contact.reload
      guard second_contact.is_primary == true
      guard other_type_contact.is_primary == true
      
      # Verify we have one primary per type
      phone_primaries = Contact.where(
        vet_office: vet_office,
        contact_type: "phone",
        is_primary: true
      ).count
      email_primaries = Contact.where(
        vet_office: vet_office,
        contact_type: "email",
        is_primary: true
      ).count
      
      guard phone_primaries <= 1
      guard email_primaries <= 1
      
      # Clean up
      contacts.each(&:destroy)
      other_type_contact.destroy
    end
  end
end
