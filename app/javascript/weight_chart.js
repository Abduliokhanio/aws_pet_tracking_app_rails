// Initialize weight chart when DOM is loaded
document.addEventListener('turbo:load', () => {
  console.log('Weight chart script loaded, Chart available:', typeof Chart !== 'undefined');
  
  const chartCanvas = document.getElementById('weightChart');
  
  if (!chartCanvas) {
    console.log('Weight chart canvas not found');
    return;
  }
  
  console.log('Weight chart canvas found');
  
  // Get data from data attributes
  const chartDataStr = chartCanvas.dataset.chartData;
  if (!chartDataStr) {
    console.log('No chart data found');
    return;
  }
  
  let chartData;
  try {
    chartData = JSON.parse(chartDataStr);
  } catch (e) {
    console.error('Error parsing chart data:', e);
    return;
  }
  
  if (!chartData.labels || chartData.labels.length === 0) {
    console.log('No labels in chart data');
    return;
  }
  
  console.log('Creating chart with data:', chartData);
  
  // Create the chart using global Chart object from CDN
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
          position: 'top',
          labels: {
            color: '#00d4ff'
          }
        },
        title: {
          display: true,
          text: 'Weight Trend Over Time',
          color: '#00d4ff',
          font: {
            size: 16
          }
        },
        tooltip: {
          mode: 'index',
          intersect: false,
          backgroundColor: 'rgba(0, 0, 0, 0.8)',
          titleColor: '#00d4ff',
          bodyColor: '#e0e0e0',
          borderColor: '#00d4ff',
          borderWidth: 1
        }
      },
      scales: {
        y: {
          beginAtZero: false,
          title: {
            display: true,
            text: 'Weight (lbs)',
            color: '#00d4ff'
          },
          ticks: {
            color: '#e0e0e0',
            callback: function(value) {
              return value.toFixed(2) + ' lbs';
            }
          },
          grid: {
            color: 'rgba(0, 212, 255, 0.1)'
          }
        },
        x: {
          title: {
            display: true,
            text: 'Date',
            color: '#00d4ff'
          },
          ticks: {
            color: '#e0e0e0',
            maxRotation: 45,
            minRotation: 45
          },
          grid: {
            color: 'rgba(0, 212, 255, 0.1)'
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
