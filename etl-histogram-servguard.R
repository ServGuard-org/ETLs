#ETL - HISTOGRAM - SERVGUARD



#Captura de dados para o histograma:
#-------------------------------------------------------------------------------
#escolhaBaseDeDados <- "SQL"
#escolhaBaseDeDados <- "CSV"
escolhaBaseDeDados <- "simulacao"

if (escolhaBaseDeDados == "SQL") {
  
  #Pacote para acessar dinamicamente o banco de dados:
  install.packages("RMySQL") 
  
  conexao <- dbConnect(RMySQL::MySQL(),
                       dbname = "ServGuard",#Nome do banco de dados
                       host = "127.0.0.1",#IP público da instância
                       port = 3306, 
                       user = "root",
                       password = "urubu100")
  
  #Variavel com o select do banco:
  select <- "" #colocar a view aqui
  
  #Chamar o select e transformar os dado recebidos em uma variavel:
  usoCpu <- dbGetQuery(conexao, select)
  
} else if (escolhaBaseDeDados == "CSV"){
  #colocar o codigo de captura dos dados por CSV aqui
  captura <- read.csv("C:/Users/cacay/Downloads/dados-pc.csv", sep=",")
  #Remove o "%" caso exista na coluna:
  usoCPU <- as.numeric(gsub("%", "", captura$CPU))  
} else {
  #Teste com valores simulados:
  n <- 100
  set.seed(22)
  usoCPU <- sample(0:100, n, replace = TRUE)
  #usoCPU <- runif(n, min = 0, max = 100)
  
}
#-------------------------------------------------------------------------------
#Captura de dados para o histograma - Fim





#Definição das faixas e plotagem do histograma:
#-------------------------------------------------------------------------------
faixas <- seq(0, 100, by=10)
histograma <- hist(usoCPU, #Dados utilizados
                   breaks=faixas, #Faixas de 10 em 10 %
                   freq=TRUE,
                   col = ("#4E2E9E"),
                   main = "Histograma de uso: CPU(%)",
                   xlab = "Faixas de uso (%)",
                   ylab = "Frequência",
                   right = FALSE, #Extende o y a maior frequencia histograma
                   xlim = c(0,100))#Fixa o valor de 0 a 100 na exibição 
                   ylim = c(0, max(histograma$counts)+2)#Fixa o valor de 0 ao max do histograma 

#Colocando o valor de frequencia em cima das colunas.
text(x = histograma$mids, #Posição x
     y = histograma$counts, #Posição y
     labels = histograma$counts, #valor do texto
     pos = 3, #Ponto aonde o texto fica, no caso 3 significa acima da coluna 
     cex = 0.8,) #Tamanho do texto

#Capturando o valor da frequencia de cada faixa do histograma:
frequencias <- histograma$counts
colunas <- histograma$breaks

#-------------------------------------------------------------------------------
#Definição das faixas e plotagem do histograma - Fim





#Inserção dos dados no Banco:
#-----------------------------------------------------------------------------------------
if (escolhaBaseDeDados == "SQL") {
  
  #Captura do mês e ano atual para o insert:
  ano_atual <- as.numeric(format(Sys.Date(), "%Y"))
  mes_atual <- as.numeric(format(Sys.Date(), "%m"))
  
  #Criando novo histograma no banco de dados
  insertHist <- sprintf(
    "INSERT INTO cpu_histogram (year, month, bars, frequency) 
      VALUES (%d, %d, %f, %f, %d);",
    ano_atual, mes_atual, frequencias[i], colunas[i]
  )
  #exectuar o insert
  dbExecute(conexao, insert)
  
  #Inserindo os valores do histograma criado no banco de dados
  for (i in 1:length(frequencias)) {
    insert <- sprintf(
      "INSERT INTO cpu_histogram (year, month, bars, frequency) 
      VALUES (%d, %d, %f, %f, %d);",
      ano_atual, mes_atual, frequencias[i], colunas[i]
    )
    #exectuar o insert
    dbExecute(conexao, insert)
  }
}
#-------------------------------------------------------------------------------
#Inserção dos dados no Banco - Fim

  



#SCRIPT DO BANCO:

#CREATE TABLE histograma (
#  id INT AUTO_INCREMENT PRIMARY KEY,

  #precisa de uma identificacao do componente!
#  year INT NOT NULL,
#  month INT NOT NULL,

#  range_start INT NOT NULL,
#  range_end INT NOT NULL,
#  frequency INT NOT NULL
#);

#pensando em outro select
#select <- "SELECT range_start, range_end, frequency FROM cpu_histogram
#              WHERE dthCriacao > 2024-10-01 AND dthCriacao < 2024-10-31;"


#ignorar essas duas variaveis, eram utilizadas apenas no contexto de apenas
#uma tabela para o histograma
#faixas_inicio <- histograma$breaks[-length(histograma$breaks)]
#faixas_fim <- histograma$breaks[-1]