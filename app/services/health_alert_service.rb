class HealthAlertService
  def initialize(health_record)
    @health_record = health_record
    @pet = health_record.pet
  end
  
  def check_and_alert
    alerts = []
    
    begin
      alerts << check_weight_threshold
      alerts << check_activity_level
      alerts << check_declining_trends
    rescue StandardError => e
      Rails.logger.error("Health alert check failed: #{e.message}")
      # Continue execution, don't fail the health record creation
    end
    
    alerts.compact.each do |alert|
      create_alert_notification(alert)
    rescue StandardError => e
      Rails.logger.error("Alert notification failed: #{e.message}")
      # Log but don't fail
    end
  end
  
  private
  
  def check_weight_threshold
    return nil unless @health_record.weight.present?
    
    # Check for custom threshold first
    custom_threshold = @pet.pet_health_thresholds.find_by(threshold_type: 'min_weight')
    threshold = custom_threshold&.threshold_value || weight_threshold_for_species(@pet.species)
    
    if @health_record.weight < threshold
      alert_condition = "weight_below_#{threshold}"
      
      # Check if this alert has been dismissed
      return nil if DismissedAlert.dismissed?(@pet, 'low_weight', alert_condition)
      
      {
        type: 'low_weight',
        condition: alert_condition,
        message: "Weight below recommended threshold for #{@pet.species}",
        severity: 'high'
      }
    end
  end
  
  def check_activity_level
    return nil unless @health_record.activity_level.present?
    
    # Check for custom alert sensitivity
    custom_sensitivity = @pet.pet_health_thresholds.find_by(threshold_type: 'alert_sensitivity')
    sensitivity = custom_sensitivity&.threshold_value&.to_i || 1
    
    # Only alert on very_low if sensitivity is high (1), or on low/very_low if sensitivity is lower
    if @health_record.activity_level == 'very_low' || (sensitivity > 1 && @health_record.activity_level == 'low')
      alert_condition = "activity_#{@health_record.activity_level}"
      
      # Check if this alert has been dismissed
      return nil if DismissedAlert.dismissed?(@pet, 'low_activity', alert_condition)
      
      {
        type: 'low_activity',
        condition: alert_condition,
        message: "Activity level is concerning",
        severity: 'medium'
      }
    end
  end
  
  def check_declining_trends
    recent_records = @pet.health_records.recent.with_weight.limit(5)
    return nil if recent_records.count < 3
    
    weights = recent_records.pluck(:weight)
    if consistently_declining?(weights)
      alert_condition = "declining_trend_#{weights.count}_records"
      
      # Check if this alert has been dismissed
      return nil if DismissedAlert.dismissed?(@pet, 'declining_trend', alert_condition)
      
      {
        type: 'declining_trend',
        condition: alert_condition,
        message: "Weight has been declining over recent records",
        severity: 'high'
      }
    end
  end
  
  def consistently_declining?(values)
    values.each_cons(2).all? { |a, b| a > b }
  end
  
  def weight_threshold_for_species(species)
    # Species-specific thresholds
    thresholds = {
      'dog' => 5.0,
      'cat' => 3.0,
      'bird' => 0.1
    }
    thresholds[species.downcase] || 1.0
  end
  
  def create_alert_notification(alert)
    # Create notification record or trigger email/push notification
    Rails.logger.info("Health alert generated: #{alert[:type]} - #{alert[:message]} (severity: #{alert[:severity]})")
  end
end
