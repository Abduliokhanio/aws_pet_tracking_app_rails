require "test_helper"

class AddressTest < ActiveSupport::TestCase
  # Property 31: Address required fields
  # Validates: Requirements 7.1
  # For any address creation attempt, the address should be rejected if city, state,
  # zipcode, or country is missing, and accepted when all are present.
  test "property: address required fields" do
    vet_office = vet_offices(:one)
    
    Rantly(20) do
      # Generate random valid values for all fields
      city = choose("New York", "Los Angeles", "Chicago", "Houston", "Phoenix")
      state = choose("NY", "CA", "IL", "TX", "AZ", "FL", "WA")
      zipcode = choose("12345", "90210", "60601", "77001", "85001")
      country = choose("US", "CA", "UK", "AU")
      
      # Test 1: Address WITHOUT city should be rejected
      addr_without_city = Address.new(
        vet_office: vet_office,
        state: state,
        zipcode: zipcode,
        country: country
      )
      guard !addr_without_city.valid?
      guard addr_without_city.errors[:city].present?
      
      # Test 2: Address WITHOUT state should be rejected
      addr_without_state = Address.new(
        vet_office: vet_office,
        city: city,
        zipcode: zipcode,
        country: country
      )
      guard !addr_without_state.valid?
      guard addr_without_state.errors[:state].present?
      
      # Test 3: Address WITHOUT zipcode should be rejected
      addr_without_zipcode = Address.new(
        vet_office: vet_office,
        city: city,
        state: state,
        country: country
      )
      guard !addr_without_zipcode.valid?
      guard addr_without_zipcode.errors[:zipcode].present?
      
      # Test 4: Address WITHOUT country should be rejected
      addr_without_country = Address.new(
        vet_office: vet_office,
        city: city,
        state: state,
        zipcode: zipcode
      )
      guard !addr_without_country.valid?
      guard addr_without_country.errors[:country].present?
      
      # Test 5: Address WITH all required fields should be accepted
      addr_with_all = Address.new(
        vet_office: vet_office,
        city: city,
        state: state,
        zipcode: zipcode,
        country: country
      )
      guard addr_with_all.valid?
      guard addr_with_all.save
      
      # Verify the address persists correctly
      retrieved = Address.find(addr_with_all.id)
      guard retrieved.city == city
      guard retrieved.state == state
      guard retrieved.zipcode == zipcode
      guard retrieved.country == country
      
      # Clean up
      addr_with_all.destroy
    end
  end

  # Property 32: Country-specific zipcode validation
  # Validates: Requirements 7.2
  # For any address with country set to 'US', the zipcode should be rejected if it
  # doesn't match US format (5 digits or 5+4 digits), and accepted if it matches.
  test "property: country-specific zipcode validation" do
    vet_office = vet_offices(:one)
    
    Rantly(20) do
      city = choose("New York", "Los Angeles", "Chicago", "Houston")
      state = choose("NY", "CA", "IL", "TX", "AZ", "FL")
      
      # Test 1: US addresses with valid 5-digit zipcode should be accepted
      valid_5_digit = "#{range(10000, 99999)}"
      addr_valid_5 = Address.new(
        vet_office: vet_office,
        city: city,
        state: state,
        zipcode: valid_5_digit,
        country: "US"
      )
      guard addr_valid_5.valid?
      guard addr_valid_5.save
      
      # Test 2: US addresses with valid 5+4 zipcode should be accepted
      valid_9_digit = "#{range(10000, 99999)}-#{range(1000, 9999)}"
      addr_valid_9 = Address.new(
        vet_office: vet_office,
        city: city,
        state: state,
        zipcode: valid_9_digit,
        country: "US"
      )
      guard addr_valid_9.valid?
      guard addr_valid_9.save
      
      # Test 3: US addresses with invalid zipcode format should be rejected
      invalid_zipcode = choose(
        "1234",        # Too short
        "123456",      # Too long (6 digits)
        "ABCDE",       # Letters
        "12345-123",   # Wrong format (5+3)
        "12-3456",     # Wrong format
        "12 345"       # Space instead of dash
      )
      
      addr_invalid = Address.new(
        vet_office: vet_office,
        city: city,
        state: state,
        zipcode: invalid_zipcode,
        country: "US"
      )
      guard !addr_invalid.valid?
      guard addr_invalid.errors[:zipcode].present?
      
      # Test 4: Non-US addresses should not validate zipcode format
      non_us_country = choose("CA", "UK", "AU", "FR", "DE")
      non_us_zipcode = choose("M5H 2N2", "SW1A 1AA", "2000", "75001", "ABC123")
      
      addr_non_us = Address.new(
        vet_office: vet_office,
        city: city,
        state: state,
        zipcode: non_us_zipcode,
        country: non_us_country
      )
      # Should be valid because zipcode format validation only applies to US
      guard addr_non_us.valid?
      guard addr_non_us.save
      
      # Clean up
      addr_valid_5.destroy
      addr_valid_9.destroy
      addr_non_us.destroy
    end
  end

  # Property 33: Address formatting
  # Validates: Requirements 7.3
  # For any address, calling the formatted method should return a string containing
  # city, state, zipcode, and country in a consistent format.
  test "property: address formatting" do
    vet_office = vet_offices(:one)
    
    Rantly(20) do
      city = choose("New York", "Los Angeles", "Chicago", "Houston", "Phoenix")
      state = choose("NY", "CA", "IL", "TX", "AZ", "FL", "WA")
      zipcode = choose("12345", "90210", "60601", "77001", "85001")
      country = choose("US", "CA", "UK", "AU")
      
      address = Address.create!(
        vet_office: vet_office,
        city: city,
        state: state,
        zipcode: zipcode,
        country: country
      )
      
      formatted = address.formatted
      
      # Verify the formatted string contains all components
      guard formatted.include?(city)
      guard formatted.include?(state)
      guard formatted.include?(zipcode)
      guard formatted.include?(country)
      
      # Verify the format matches the expected pattern: "city, state zipcode, country"
      expected_format = "#{city}, #{state} #{zipcode}, #{country}"
      guard formatted == expected_format
      
      # Clean up
      address.destroy
    end
  end

  # Property 34: Address-office one-to-one
  # Validates: Requirements 7.4
  # For any address, the address should be associated with exactly one vet office.
  test "property: address-office one-to-one" do
    vet_office = vet_offices(:one)
    
    Rantly(20) do
      city = choose("New York", "Los Angeles", "Chicago", "Houston")
      state = choose("NY", "CA", "IL", "TX")
      zipcode = "#{range(10000, 99999)}"
      country = choose("US", "CA", "UK")
      
      # Test 1: Address WITHOUT vet_office association should be rejected
      addr_without_office = Address.new(
        city: city,
        state: state,
        zipcode: zipcode,
        country: country
      )
      
      guard !addr_without_office.valid?
      guard addr_without_office.errors[:vet_office].present?
      guard !addr_without_office.save
      
      # Test 2: Address WITH valid vet_office association should be accepted
      addr_with_office = Address.new(
        vet_office: vet_office,
        city: city,
        state: state,
        zipcode: zipcode,
        country: country
      )
      
      guard addr_with_office.valid?
      guard addr_with_office.save
      
      # Retrieve the address and verify the vet_office association is preserved
      retrieved = Address.find(addr_with_office.id)
      guard retrieved.vet_office_id == vet_office.id
      guard retrieved.vet_office == vet_office
      
      # Verify the association is one-to-one from the vet_office side
      guard vet_office.address == retrieved
      
      # Clean up
      addr_with_office.destroy
    end
  end
end
