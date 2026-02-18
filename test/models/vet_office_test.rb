require "test_helper"

class VetOfficeTest < ActiveSupport::TestCase
  # Property 26: Vet office required fields
  # Validates: Requirements 6.1
  # For any vet office creation attempt, the office should be rejected if name is
  # missing, and accepted when name is present.
  test "property: vet office required fields" do
    Rantly(20) do
      # Generate random name
      name = choose("Happy Paws Clinic", "City Animal Hospital", "Pet Care Center", "Veterinary Associates")
      
      # Test 1: VetOffice WITHOUT name should be rejected
      office_without_name = VetOffice.new
      guard !office_without_name.valid?
      guard office_without_name.errors[:name].present?
      guard !office_without_name.save
      
      # Test 2: VetOffice WITH name should be accepted
      office_with_name = VetOffice.new(name: name)
      guard office_with_name.valid?
      guard office_with_name.save
      
      # Verify the office persists correctly
      retrieved = VetOffice.find(office_with_name.id)
      guard retrieved.name == name
      
      # Clean up
      office_with_name.destroy
    end
  end

  # Property 27: Vet office associations
  # Validates: Requirements 6.2
  # For any vet office, querying the office should load the associated address
  # and all contacts.
  test "property: vet office associations" do
    Rantly(20) do
      # Create a vet office
      office_name = choose("Happy Paws Clinic", "City Animal Hospital", "Pet Care Center")
      office = VetOffice.create!(name: office_name)
      
      # Create an associated address
      address = Address.create!(
        vet_office: office,
        city: choose("New York", "Los Angeles", "Chicago", "Houston"),
        state: choose("NY", "CA", "IL", "TX"),
        zipcode: "#{range(10000, 99999)}",
        country: choose("US", "CA", "UK")
      )
      
      # Create multiple contacts
      num_contacts = range(1, 5)
      contacts = []
      num_contacts.times do |i|
        contact_type = choose("phone", "email")
        contact_value = if contact_type == "phone"
          "#{range(1000000000, 9999999999)}"
        else
          "test#{i}@example.com"
        end
        
        contacts << Contact.create!(
          vet_office: office,
          contact_type: contact_type,
          contact_value: contact_value,
          is_primary: (i == 0)
        )
      end
      
      # Query the office and verify associations are loaded
      retrieved_office = VetOffice.find(office.id)
      
      # Verify address association
      guard retrieved_office.address.present?
      guard retrieved_office.address.id == address.id
      guard retrieved_office.address.city == address.city
      
      # Verify contacts association
      guard retrieved_office.contacts.count == num_contacts
      retrieved_contacts = retrieved_office.contacts.to_a
      guard retrieved_contacts.size == num_contacts
      
      # Verify all created contacts are associated
      contacts.each do |contact|
        guard retrieved_contacts.map(&:id).include?(contact.id)
      end
      
      # Clean up
      office.destroy
    end
  end

  # Property 28: Office-address one-to-one
  # Validates: Requirements 6.3
  # For any vet office, the office should have exactly one associated address.
  test "property: office-address one-to-one" do
    Rantly(20) do
      # Create a vet office
      office_name = choose("Happy Paws Clinic", "City Animal Hospital", "Pet Care Center")
      office = VetOffice.create!(name: office_name)
      
      # Test 1: Office can have one address
      address1 = Address.create!(
        vet_office: office,
        city: choose("New York", "Los Angeles", "Chicago"),
        state: choose("NY", "CA", "IL"),
        zipcode: "#{range(10000, 99999)}",
        country: "US"
      )
      
      # Verify the office has exactly one address
      guard office.address.present?
      guard office.address.id == address1.id
      
      # Test 2: Verify the one-to-one relationship from address side
      retrieved_address = Address.find(address1.id)
      guard retrieved_address.vet_office_id == office.id
      guard retrieved_address.vet_office == office
      
      # Test 3: Verify only one address exists for this office
      guard Address.where(vet_office: office).count == 1
      
      # Test 4: When office is destroyed, address should be destroyed (dependent: :destroy)
      office_id = office.id
      address_id = address1.id
      
      office.destroy
      
      # Verify both office and address are destroyed
      guard !VetOffice.exists?(office_id)
      guard !Address.exists?(address_id)
    end
  end
end
