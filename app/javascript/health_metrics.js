import { Chart, registerables } from 'chart.js';

// Register Chart.js components
Chart.register(...registerables);

// Initialize health metrics charts when DOM is loaded
document.addEventListener('turbo:load', () => {
  initializeMoodChart();
  initializeActivityChart();
  initializeFoodIntakeChart();
});

function initializeMoodChart() {
  const chartCanvas = document.getElementById('moodChart');
  
  if (!chartCanvas) return;
  
  const metricsData = JSON.parse(chartCanvas.dataset.metricsData || '{}');
  const moodData = metricsData.mood || {};
  
  if (Object.keys(moodData).length === 0) {
    return;
  }
  
  const ctx = chartCanvas.getContext('2d');
  new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: Object.keys(moodData).map(key => capitalizeFirst(key)),
      datasets: [{
        label: 'Mood Distribution',
        data: Object.values(moodData),
        backgroundColor: [
          'rgba(255, 206, 86, 0.8)',
          'rgba(75, 192, 192, 0.8)',
          'rgba(54, 162, 235, 0.8)',
          'rgba(153, 102, 255, 0.8)',
          'rgba(255, 99, 132, 0.8)'
        ],
        borderColor: [
          'rgba(255, 206, 86, 1)',
          'rgba(75, 192, 192, 1)',
          'rgba(54, 162, 235, 1)',
          'rgba(153, 102, 255, 1)',
          'rgba(255, 99, 132, 1)'
        ],
        borderWidth: 2
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: true,
          position: 'right'
        },
        title: {
          display: true,
          text: 'Mood Distribution',
          font: {
            size: 16
          }
        },
        tooltip: {
          callbacks: {
            label: function(context) {
              const label = context.label || '';
              const value = context.parsed || 0;
              const total = context.dataset.data.reduce((a, b) => a + b, 0);
              const percentage = ((value / total) * 100).toFixed(1);
              return `${label}: ${value} (${percentage}%)`;
            }
          }
        }
      }
    }
  });
}

function initializeActivityChart() {
  const chartCanvas = document.getElementById('activityChart');
  
  if (!chartCanvas) return;
  
  const metricsData = JSON.parse(chartCanvas.dataset.metricsData || '{}');
  const activityData = metricsData.activity_level || {};
  
  if (Object.keys(activityData).length === 0) {
    return;
  }
  
  const ctx = chartCanvas.getContext('2d');
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: Object.keys(activityData).map(key => capitalizeFirst(key.replace('_', ' '))),
      datasets: [{
        label: 'Activity Level',
        data: Object.values(activityData),
        backgroundColor: 'rgba(54, 162, 235, 0.8)',
        borderColor: 'rgba(54, 162, 235, 1)',
        borderWidth: 2
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: false
        },
        title: {
          display: true,
          text: 'Activity Level Distribution',
          font: {
            size: 16
          }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          ticks: {
            stepSize: 1
          },
          title: {
            display: true,
            text: 'Number of Records'
          }
        },
        x: {
          title: {
            display: true,
            text: 'Activity Level'
          }
        }
      }
    }
  });
}

function initializeFoodIntakeChart() {
  const chartCanvas = document.getElementById('foodIntakeChart');
  
  if (!chartCanvas) return;
  
  const metricsData = JSON.parse(chartCanvas.dataset.metricsData || '{}');
  const foodData = metricsData.food_intake || {};
  
  if (Object.keys(foodData).length === 0) {
    return;
  }
  
  const ctx = chartCanvas.getContext('2d');
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: Object.keys(foodData).map(key => capitalizeFirst(key.replace('_', ' '))),
      datasets: [{
        label: 'Food Intake',
        data: Object.values(foodData),
        backgroundColor: 'rgba(75, 192, 192, 0.8)',
        borderColor: 'rgba(75, 192, 192, 1)',
        borderWidth: 2
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: false
        },
        title: {
          display: true,
          text: 'Food Intake Distribution',
          font: {
            size: 16
          }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          ticks: {
            stepSize: 1
          },
          title: {
            display: true,
            text: 'Number of Records'
          }
        },
        x: {
          title: {
            display: true,
            text: 'Food Intake Level'
          }
        }
      }
    }
  });
}

// Helper function to capitalize first letter
function capitalizeFirst(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

// Export for use in other modules if needed
export { initializeMoodChart, initializeActivityChart, initializeFoodIntakeChart };
