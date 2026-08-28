document.addEventListener('DOMContentLoaded', () => {
    console.log('BS Financeiro - App Iniciado');

    // Funcao utilitaria basica para formatar moeda (exemplo)
    window.formatCurrency = (value) => {
        return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);
    };

    // Inicializar Grafico de Despesas se existir
    const ctx = document.getElementById('expensesChart');
    if (ctx && window.chartData && window.chartData.length > 0) {
        const labels = window.chartData.map(c => c.category_name);
        const data = window.chartData.map(c => parseFloat(c.total));
        const colors = window.chartData.map(c => c.category_color);

        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: labels,
                datasets: [{
                    data: data,
                    backgroundColor: colors,
                    borderWidth: 2,
                    borderColor: '#1C1C1E',
                    borderRadius: 8,
                    hoverOffset: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '75%',
                plugins: {
                    legend: { display: false }
                }
            }
        });
    }
});
