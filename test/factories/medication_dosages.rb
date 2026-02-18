FactoryBot.define do
  factory :medication_dosage do
    medication { nil }
    dose { "9.99" }
    recorded_on { "2026-02-18" }
    notes { "MyText" }
  end
end
