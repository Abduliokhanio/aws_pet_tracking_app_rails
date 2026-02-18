import { Chart, registerables } from 'chart.js';

// Register Chart.js components
Chart.register(...registerables);

// Initialize weight chart when DOM is loaded
document.addEventListener('turbo:load', () => {
  const chartCanvas = document.getElementById('weightChart');
  
  if (!chartCanvas) return;
  
  // Get data from data attributes
  const chartData = JSON.parse(chartCanvas.dataset.chartData || '{}');
  
  if (!chartData.labels || chartData.labels.length === 0) {
    return;
  }
  
  // Create the chart
  const ctx = chartCanvas.getContext('2d');
  new Chart(ctx, {
    type: 'line',
    data: chartData,
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: true,
          position: 'top'
        },
        title: {
          display: true,
          text: 'Weight Trend Over Time'
        },
        tooltip: {
          mode: 'index',
          intersect: false
        }
      },
      scales: {
        y: {
          beginAtZero: false,
          title: {
            display: true,
            text: 'Weight (lbs)'
          },
          ticks: {
            callback: function(value) {
              return value.toFixed(2) + ' lbs';
            }
          }
        },
        x: {
          title: {
            display: true,
            text: 'Date'
          },
          ticks: {
            maxRotation: 45,
            minRotation: 45
          }
        }
      },
      interaction: {
        mode: 'nearest',
        axis: 'x',
        intersect: false
      }
    }
  });
});

// Export for use in other modules if needed
export function initializeWeightChart(canvasId, data) {
  const canvas = document.getElementById(canvasId);
  if (!canvas) return null;
  
  const ctx = canvas.getContext('2d');
  return new Chart(ctx, {
    type: 'line',
    data: data,
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: true,
          position: 'top'
        },
        title: {
          display: true,
          text: 'Weight Trend Over Time'
        }
      },
      scales: {
        y: {
          beginAtZero: false,
          title: {
            display: true,
            text: 'Weight (lbs)'
          }
        },
        x: {
          title: {
            display: true,
            text: 'Date'
          }
        }
      }
    }
  });
}
