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
    
    threshold = weight_threshold_for_species(@pet.species)
    if @health_record.weight < threshold
      {
        type: 'low_weight',
        message: "Weight below recommended threshold for #{@pet.species}",
        severity: 'high'
      }
    end
  end
  
  def check_activity_level
    return nil unless @health_record.activity_level.present?
    
    if @health_record.activity_level == 'very_low'
      {
        type: 'low_activity',
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
      {
        type: 'declining_trend',
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
