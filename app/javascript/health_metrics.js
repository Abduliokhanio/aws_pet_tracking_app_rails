// Initialize health metrics charts when DOM is loaded
document.addEventListener('turbo:load', () => {
  // Mood Chart
  const moodCanvas = document.getElementById('moodChart');
  if (moodCanvas) {
    const metricsData = JSON.parse(moodCanvas.dataset.metricsData || '{}');
    if (metricsData.mood) {
      const ctx = moodCanvas.getContext('2d');
      new Chart(ctx, {
        type: 'pie',
        data: {
          labels: Object.keys(metricsData.mood),
          datasets: [{
            data: Object.values(metricsData.mood),
            backgroundColor: [
              'rgba(255, 99, 132, 0.8)',
              'rgba(54, 162, 235, 0.8)',
              'rgba(255, 206, 86, 0.8)',
              'rgba(75, 192, 192, 0.8)',
              'rgba(153, 102, 255, 0.8)'
            ],
            borderColor: '#00d4ff',
            borderWidth: 2
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              position: 'bottom',
              labels: { color: '#00d4ff' }
            },
            title: {
              display: true,
              text: 'Mood Distribution',
              color: '#00d4ff'
            }
          }
        }
      });
    }
  }

  // Activity Chart
  const activityCanvas = document.getElementById('activityChart');
  if (activityCanvas) {
    const metricsData = JSON.parse(activityCanvas.dataset.metricsData || '{}');
    if (metricsData.activity_level) {
      const ctx = activityCanvas.getContext('2d');
      new Chart(ctx, {
        type: 'bar',
        data: {
          labels: Object.keys(metricsData.activity_level),
          datasets: [{
            label: 'Activity Level',
            data: Object.values(metricsData.activity_level),
            backgroundColor: 'rgba(0, 212, 255, 0.6)',
            borderColor: '#00d4ff',
            borderWidth: 2
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              labels: { color: '#00d4ff' }
            },
            title: {
              display: true,
              text: 'Activity Level',
              color: '#00d4ff'
            }
          },
          scales: {
            y: {
              beginAtZero: true,
              ticks: { color: '#e0e0e0' },
              grid: { color: 'rgba(0, 212, 255, 0.1)' }
            },
            x: {
              ticks: { color: '#e0e0e0' },
              grid: { color: 'rgba(0, 212, 255, 0.1)' }
            }
          }
        }
      });
    }
  }

  // Food Intake Chart
  const foodCanvas = document.getElementById('foodIntakeChart');
  if (foodCanvas) {
    const metricsData = JSON.parse(foodCanvas.dataset.metricsData || '{}');
    if (metricsData.food_intake) {
      const ctx = foodCanvas.getContext('2d');
      new Chart(ctx, {
        type: 'doughnut',
        data: {
          labels: Object.keys(metricsData.food_intake),
          datasets: [{
            data: Object.values(metricsData.food_intake),
            backgroundColor: [
              'rgba(255, 99, 132, 0.8)',
              'rgba(54, 162, 235, 0.8)',
              'rgba(255, 206, 86, 0.8)',
              'rgba(75, 192, 192, 0.8)'
            ],
            borderColor: '#00d4ff',
            borderWidth: 2
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              position: 'bottom',
              labels: { color: '#00d4ff' }
            },
            title: {
              display: true,
              text: 'Food Intake',
              color: '#00d4ff'
            }
          }
        }
      });
    }
  }
});
