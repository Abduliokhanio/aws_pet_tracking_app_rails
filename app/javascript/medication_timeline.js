import { Chart, registerables } from 'chart.js';

// Register Chart.js components
Chart.register(...registerables);

// Initialize medication timeline chart when DOM is loaded
document.addEventListener('turbo:load', () => {
  const chartCanvas = document.getElementById('medicationTimelineChart');
  
  if (!chartCanvas) return;
  
  // Get data from data attributes
  const timelineData = JSON.parse(chartCanvas.dataset.timelineData || '[]');
  
  if (timelineData.length === 0) {
    return;
  }
  
  // Transform timeline data into Chart.js format
  const datasets = timelineData.map((med, index) => {
    const startDate = new Date(med.start);
    const endDate = new Date(med.end);
    
    return {
      label: `${med.name} (${med.dose})`,
      data: [
        { x: startDate, y: index },
        { x: endDate, y: index }
      ],
      borderColor: med.active ? 'rgb(76, 175, 80)' : 'rgb(158, 158, 158)',
      backgroundColor: med.active ? 'rgba(76, 175, 80, 0.2)' : 'rgba(158, 158, 158, 0.2)',
      borderWidth: 3,
      pointRadius: 5,
      pointHoverRadius: 7,
      showLine: true,
      tension: 0
    };
  });
  
  // Create the chart
  const ctx = chartCanvas.getContext('2d');
  new Chart(ctx, {
    type: 'line',
    data: {
      datasets: datasets
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: true,
          position: 'top',
          labels: {
            usePointStyle: true,
            padding: 15
          }
        },
        title: {
          display: true,
          text: 'Medication Timeline',
          font: {
            size: 16
          }
        },
        tooltip: {
          callbacks: {
            label: function(context) {
              const med = timelineData[context.datasetIndex];
              const date = new Date(context.parsed.x);
              return [
                `${med.name}`,
                `Dose: ${med.dose}`,
                `Date: ${date.toLocaleDateString()}`,
                `Status: ${med.active ? 'Active' : 'Inactive'}`
              ];
            }
          }
        }
      },
      scales: {
        x: {
          type: 'time',
          time: {
            unit: 'month',
            displayFormats: {
              month: 'MMM yyyy'
            }
          },
          title: {
            display: true,
            text: 'Date'
          }
        },
        y: {
          display: false,
          min: -0.5,
          max: timelineData.length - 0.5
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
export function initializeMedicationTimeline(canvasId, timelineData) {
  const canvas = document.getElementById(canvasId);
  if (!canvas) return null;
  
  const datasets = timelineData.map((med, index) => {
    const startDate = new Date(med.start);
    const endDate = new Date(med.end);
    
    return {
      label: `${med.name} (${med.dose})`,
      data: [
        { x: startDate, y: index },
        { x: endDate, y: index }
      ],
      borderColor: med.active ? 'rgb(76, 175, 80)' : 'rgb(158, 158, 158)',
      backgroundColor: med.active ? 'rgba(76, 175, 80, 0.2)' : 'rgba(158, 158, 158, 0.2)',
      borderWidth: 3,
      showLine: true
    };
  });
  
  const ctx = canvas.getContext('2d');
  return new Chart(ctx, {
    type: 'line',
    data: { datasets: datasets },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        x: {
          type: 'time',
          time: {
            unit: 'month'
          },
          title: {
            display: true,
            text: 'Date'
          }
        },
        y: {
          display: false
        }
      }
    }
  });
}
