class VisualizationService
  def initialize(pet, start_date: 6.months.ago, end_date: Date.today)
    @pet = pet
    @start_date = start_date
    @end_date = end_date
  end
  
  def weight_chart_data
    records = @pet.health_records
                  .where(recorded_on: @start_date..@end_date)
                  .with_weight
                  .chronological
                  .reverse
    
    {
      labels: records.map { |r| r.recorded_on.strftime('%b %d, %Y') },
      datasets: [{
        label: 'Weight (lbs)',
        data: records.pluck(:weight),
        borderColor: '#00d4ff',
        backgroundColor: 'rgba(0, 212, 255, 0.1)',
        tension: 0.4,
        fill: true
      }]
    }
  end
  
  def medication_timeline_data
    medications = @pet.medications
                      .where('start_date <= ? AND (end_date IS NULL OR end_date >= ?)', 
                             @end_date, @start_date)
    
    medications.map do |med|
      {
        name: med.medication_name,
        dose: med.dose,
        start: med.start_date,
        end: med.end_date || Date.today,
        active: med.active?
      }
    end
  end
  
  def health_metrics_data
    records = @pet.health_records
                  .where(recorded_on: @start_date..@end_date)
                  .chronological
    
    {
      mood: aggregate_by_category(records, :mood),
      activity_level: aggregate_by_category(records, :activity_level),
      food_intake: aggregate_by_category(records, :food_intake)
    }
  end
  
  private
  
  def aggregate_by_category(records, attribute)
    records.where.not(attribute => nil)
           .group(attribute)
           .count
  end
end
