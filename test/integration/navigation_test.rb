require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @pet = pets(:one)
  end

  test "can navigate to vet offices from main navigation" do
    get root_path
    assert_response :success
    assert_select "a[href=?]", vet_offices_path
  end

  test "can navigate to veterinarians from main navigation" do
    get root_path
    assert_response :success
    assert_select "a[href=?]", veterinarians_path
  end

  test "can navigate to health dashboard from pet show page" do
    get user_pet_path(@user, @pet)
    assert_response :success
    assert_select "a[href=?]", dashboard_user_pet_path(@user, @pet)
  end

  test "can navigate to health records from pet show page" do
    get user_pet_path(@user, @pet)
    assert_response :success
    assert_select "a[href=?]", pet_health_records_path(@pet)
  end

  test "can navigate to medications from pet show page" do
    get user_pet_path(@user, @pet)
    assert_response :success
    assert_select "a[href=?]", pet_medications_path(@pet)
  end

  test "can navigate to reminders from pet show page" do
    get user_pet_path(@user, @pet)
    assert_response :success
    assert_select "a[href=?]", pet_reminders_path(@pet)
  end

  test "dashboard displays all sections" do
    get dashboard_user_pet_path(@user, @pet)
    assert_response :success
    
    # Check for main sections
    assert_select "h1", text: /Health Dashboard for #{@pet.name}/
    assert_select "h2", text: /Recent Health Records/
    assert_select "h2", text: /Active Medications/
    assert_select "h2", text: /Upcoming Reminders/
    assert_select "h3", text: /Quick Actions/
  end

  test "dashboard has links to all health management features" do
    get dashboard_user_pet_path(@user, @pet)
    assert_response :success
    
    # Check for quick action links
    assert_select "a[href=?]", new_pet_health_record_path(@pet)
    assert_select "a[href=?]", new_pet_medication_path(@pet)
    assert_select "a[href=?]", new_pet_reminder_path(@pet)
    
    # Check for view all links
    assert_select "a[href=?]", pet_health_records_path(@pet)
    assert_select "a[href=?]", pet_medications_path(@pet)
    assert_select "a[href=?]", pet_reminders_path(@pet)
  end

  test "can access all health record routes" do
    get pet_health_records_path(@pet)
    assert_response :success
    
    get new_pet_health_record_path(@pet)
    assert_response :success
  end

  test "can access all medication routes" do
    get pet_medications_path(@pet)
    assert_response :success
    
    get new_pet_medication_path(@pet)
    assert_response :success
  end

  test "can access all reminder routes" do
    get pet_reminders_path(@pet)
    assert_response :success
    
    get new_pet_reminder_path(@pet)
    assert_response :success
  end

  test "can access vet office routes" do
    get vet_offices_path
    assert_response :success
    
    get new_vet_office_path
    assert_response :success
  end

  test "can access veterinarian routes" do
    get veterinarians_path
    assert_response :success
    
    get new_veterinarian_path
    assert_response :success
  end
end
