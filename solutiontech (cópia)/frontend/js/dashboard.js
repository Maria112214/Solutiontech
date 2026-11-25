const API_URL = "http://127.0.0.1:8000";
const areaGraficos = document.querySelector("#graficos");
const avisoGraficos = document.querySelector("#aviso-graficos");
const botao = document.querySelector("#botao-atualizar");
const elementoPeriodo = document.querySelector("#periodo");
let instanciadas = [];

// Configurações globais de estilo para o Chart.js no modo Dark
Chart.defaults.color = "#94a3b8";
Chart.defaults.font.family = "'Inter', sans-serif";
Chart.defaults.borderColor = "rgba(255, 255, 255, 0.05)";

function dataBrasil(dataStr) {
  if (!dataStr) return "—";
  return dataStr.split("-").reverse().join("/");
}

function formatarCategoria(texto) {
  const mapa = {
    alimentacao: "Alimentação",
    abrigo: "Abrigo",
    roupas: "Roupas",
    assistencia_social: "Assistência Social",
    higiene: "Higiene",
  };
  const chave = String(texto || "").trim().toLowerCase();
  if (mapa[chave]) return mapa[chave];
  return chave
    .replace(/_/g, " ")
    .replace(/\b\w/g, letra => letra.toUpperCase());
}

async function consultarAPI(caminho) {
  const resp = await fetch(API_URL + caminho);
  if (!resp.ok) throw new Error("Erro na rota: " + caminho);
  return await resp.json();
}

function limparGraficos() {
  instanciadas.forEach(g => g.destroy());
  instanciadas = [];
}

function desenharUmGrafico(idCanvas, tipoGrafico, rotulos, dadosNumericos, titulo, cores, eTemporal = false) {
  const elementoCanvas = document.getElementById(idCanvas);
  if (!elementoCanvas) return;
  const ctx = elementoCanvas.getContext("2d");

  let backgroundColor = cores;
  if (tipoGrafico === "line") {
    const gradient = ctx.createLinearGradient(0, 0, 0, 280);
    gradient.addColorStop(0, "rgba(59, 130, 246, 0.35)");
    gradient.addColorStop(1, "rgba(59, 130, 246, 0.0)");
    backgroundColor = gradient;
  } else if (typeof cores === "string") {
    const gradient = ctx.createLinearGradient(0, 0, 0, 280);
    gradient.addColorStop(0, "#8b5cf6");
    gradient.addColorStop(1, "rgba(139, 92, 246, 0.25)");
    backgroundColor = gradient;
  }

  const novoGrafico = new Chart(ctx, {
    type: tipoGrafico,
    data: {
      labels: rotulos,
      datasets: [{
        label: titulo,
        data: dadosNumericos,
        backgroundColor: backgroundColor,
        borderColor: tipoGrafico === "line" ? "#3b82f6" : "transparent",
        borderWidth: tipoGrafico === "line" ? 2.5 : 0,
        borderRadius: tipoGrafico === "bar" ? 6 : 0,
        maxBarThickness: 22,
        pointBackgroundColor: "#60a5fa",
        pointBorderColor: "#0f172a",
        pointBorderWidth: 2,
        pointRadius: tipoGrafico === "line" ? 2 : 0,
        pointHoverRadius: 6,
        fill: true,
        tension: 0.35
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      interaction: {
        mode: "index",
        intersect: false
      },
      plugins: {
        legend: { display: false },
        tooltip: {
          backgroundColor: "#0f172a",
          titleColor: "#f8fafc",
          bodyColor: "#cbd5e1",
          borderColor: "rgba(255, 255, 255, 0.12)",
          borderWidth: 1,
          padding: 12,
          displayColors: false
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          ticks: { precision: 0, color: "#94a3b8" },
          grid: { color: "rgba(255, 255, 255, 0.05)" }
        },
        x: {
          ticks: {
            color: "#94a3b8",
            maxRotation: 0,
            autoSkip: true,
            maxTicksLimit: eTemporal ? 10 : 8,
            callback: function (valor) {
              const texto = this.getLabelForValue(valor);
              return eTemporal && texto.length === 10 ? texto.slice(0, 5) : texto;
            }
          },
          grid: { display: false }
        }
      }
    }
  });

  instanciadas.push(novoGrafico);
}

async function carregarPainel() {
  try {
    if (avisoGraficos) {
      avisoGraficos.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> A carregar dados...';
    }

    limparGraficos();

    const [resumo, tipos, status, dias, faturamento] = await Promise.all([
      consultarAPI("/analise/resumo"),
      consultarAPI("/analise/tipos"),
      consultarAPI("/analise/status"),
      consultarAPI("/dashboard/compras-por-dia"),
      consultarAPI("/dashboard/faturamento-por-dia")
    ]);

    // 1. Mapeamento dos Tipos de Ajuda com nomes formatados
    let tiposLista = [];
    if (Array.isArray(tipos)) {
      tiposLista = tipos;
    } else if (tipos && typeof tipos === "object") {
      tiposLista = tipos.por_tipo || tipos.tipos || tipos.por_forma_pagamento || tipos.dados || [];
    }

    const rotulosTipos = tiposLista.map(item =>
      formatarCategoria(item.tipo || item.tipo_ajuda || item.forma_pagamento || item.nome || item.label || Object.values(item)[0] || "Outros")
    );
    const valoresTipos = tiposLista.map(item =>
      item.total_solicitacoes || item.total_compras || item.total || item.quantidade || item.qtd || Object.values(item)[1] || 0
    );

    // 2. Preenchimento dos KPIs (mantém o total geral do ano inteiro)
    document.querySelector("#total-compras").textContent = Number(resumo.total_solicitacoes || resumo.total_compras || 0).toLocaleString("pt-BR");
    document.querySelector("#total-clientes").textContent = Number(resumo.total_totens || resumo.total_clientes || 0).toLocaleString("pt-BR");

    const totalTipos = resumo.total_tipos || resumo.total_produtos || tiposLista.length || 0;
    document.querySelector("#total-produtos").textContent = totalTipos;

    // 3. Atualização do Período no Topo
    if (dias && dias.length > 0) {
      const primeiraData = dataBrasil(dias[0].data);
      const ultimaData = dataBrasil(dias[dias.length - 1].data);
      if (elementoPeriodo) elementoPeriodo.textContent = `${primeiraData} até ${ultimaData}`;
    } else if (elementoPeriodo) {
      elementoPeriodo.textContent = "Consulta concluída.";
    }

    areaGraficos.hidden = false;
    if (avisoGraficos) avisoGraficos.hidden = true;

    // 4. Gráfico 1: Solicitações por Tipo
    const paletaCores = ["#3b82f6", "#8b5cf6", "#ec4899", "#10b981", "#f59e0b", "#06b6d4", "#a855f7"];
    desenharUmGrafico(
      "grafico-pagamentos",
      "bar",
      rotulosTipos,
      valoresTipos,
      "Solicitações por Tipo",
      paletaCores,
      false
    );

    // 5. Gráfico 2: Solicitações por Dia (últimos 30 dias para leitura limpa)
    const ultimosDias = dias.slice(-30);
    const rotulosDias = ultimosDias.map(item => dataBrasil(item.data));
    const valoresDias = ultimosDias.map(item => item.total_compras || item.total_solicitacoes || item.total || 0);
    desenharUmGrafico(
      "grafico-compras",
      "bar",
      rotulosDias,
      valoresDias,
      "Solicitações por Dia",
      "#8b5cf6",
      true
    );

    // 6. Gráfico 3: Atendimentos Concluídos por Dia (últimos 30 dias)
    const ultimosFat = faturamento.slice(-30);
    const rotulosFat = ultimosFat.map(item => dataBrasil(item.data));
    const valoresFat = ultimosFat.map(item => item.faturamento || item.total_atendidas || item.total || 0);
    desenharUmGrafico(
      "grafico-faturamento",
      "line",
      rotulosFat,
      valoresFat,
      "Atendimentos Concluídos",
      "#3b82f6",
      true
    );

  } catch (erro) {
    if (avisoGraficos) {
      avisoGraficos.hidden = false;
      avisoGraficos.innerHTML = `<i class="fa-solid fa-triangle-exclamation" style="color: #ef4444;"></i> Erro ao carregar dados: ${erro.message}`;
    }
  }
}

if (botao) botao.addEventListener("click", carregarPainel);
carregarPainel();