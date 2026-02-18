// Initialize medication timeline chart when DOM is loaded
document.addEventListener('turbo:load', () => {
  const chartCanvas = document.getElementById('medicationTimelineChart');
  
  if (!chartCanvas) return;
  
  const timelineDataStr = chartCanvas.dataset.timelineData;
  if (!timelineDataStr) return;
  
  let timelineData;
  try {
    timelineData = JSON.parse(timelineDataStr);
  } catch (e) {
    console.error('Error parsing timeline data:', e);
    return;
  }
  
  if (!timelineData || timelineData.length === 0) return;
  
  // Prepare data for horizontal bar chart
  const labels = timelineData.map(med => med.name);
  const startDates = timelineData.map(med => new Date(med.start).getTime());
  const durations = timelineData.map(med => {
    const start = new Date(med.start);
    const end = new Date(med.end);
    return end.getTime() - start.getTime();
  });
  
  const ctx = chartCanvas.getContext('2d');
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: 'Medication Duration',
        data: durations.map((d, i) => ({
          x: [startDates[i], startDates[i] + d],
          y: i
        })),
        backgroundColor: timelineData.map(med => 
          med.active ? 'rgba(0, 212, 255, 0.6)' : 'rgba(128, 128, 128, 0.4)'
        ),
        borderColor: '#00d4ff',
        borderWidth: 2
      }]
    },
    options: {
      indexAxis: 'y',
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: false
        },
        title: {
          display: true,
          text: 'Medication Timeline',
          color: '#00d4ff'
        },
        tooltip: {
          callbacks: {
            label: function(context) {
              const med = timelineData[context.dataIndex];
              return `${med.dose} (${med.start} to ${med.end})`;
            }
          }
        }
      },
      scales: {
        x: {
          type: 'time',
          time: {
            unit: 'day'
          },
          ticks: { color: '#e0e0e0' },
          grid: { color: 'rgba(0, 212, 255, 0.1)' }
        },
        y: {
          ticks: { color: '#e0e0e0' },
          grid: { color: 'rgba(0, 212, 255, 0.1)' }
        }
      }
    }
  });
});
