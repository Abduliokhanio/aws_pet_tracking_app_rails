# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "weight_chart", to: "weight_chart.js"
pin "medication_timeline", to: "medication_timeline.js"
pin "health_metrics", to: "health_metrics.js"
