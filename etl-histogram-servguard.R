#ETL - HISTOGRAM - SERVGUARD



#Captura de dados para o histograma:
#-------------------------------------------------------------------------------
escolhaBaseDeDados <- "SQL"
#escolhaBaseDeDados <- "CSV"
#escolhaBaseDeDados <- "simulacao"

if (escolhaBaseDeDados == "SQL") {
  
  #Pacote para acessar dinamicamente o banco de dados:
  requireNamespace("DBI", quietly = TRUE)
  library(DBI)
  requireNamespace("RMySQL", quietly = TRUE)
  library(RMySQL)
  
  conexao <- dbConnect(RMySQL::MySQL(),
                       dbname = "ServGuard",#Nome do banco de dados
                       host = "127.0.0.1",#IP público da instância
                       port = 3306, 
                       user = "root",
                       password = "urubu100")
  
  #Variavel com o select do banco:
  select <- "SELECT * FROM vista_registro_cpu;" #colocar a view aqui
  #Chamar o select e transformar os dado recebidos em uma variavel:
  usoCPU <- dbGetQuery(conexao, select)

} else if (escolhaBaseDeDados == "CSV"){
  
  #colocar o codigo de captura dos dados por CSV aqui
  captura <- read.csv("C:/Users/cacay/Documents/Git-Hub/ServGuard-ETLs/dados-csv.csv", sep=";")
  head(captura$fkMaquinaRecurso)
  usoCPU <- as.numeric(captura$registro[captura$fkMaquinaRecurso==1])
  
} else {
  
  #Teste com valores simulados:
  n <- 100
  set.seed(22)
  usoCPU <- sample(0:100, n, replace = TRUE)

}
#-------------------------------------------------------------------------------
#Captura de dados para o histograma - Fim





#Definição das faixas e plotagem do histograma:
#-------------------------------------------------------------------------------
faixas <- seq(0, 100, by=10)
histograma <- hist(usoCPU$registro, #Dados utilizados
                   breaks=faixas, #Faixas de 10 em 10 %
                   freq=TRUE,
                   col = ("#4E2E9E"),
                   main = "Histograma de uso: CPU(%)",
                   xlab = "Faixas de uso (%)",
                   ylab = "Frequência",
                   right = FALSE, #Extende o y a maior frequencia histograma
                   xlim = c(0,100))#Fixa o valor de 0 a 100 na exibição 
                   ylim = c(0, (max(histograma$counts)+2))#Fixa o valor de 0 ao max do histograma 

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
  
  #Criando novo histograma no banco de dados
  fkEmpresa<-1
  insertHist <- sprintf(
    "INSERT INTO Histograma (fkEmpresa) VALUE (%d);",
    fkEmpresa
  )
  #Exectuar o insert
  dbExecute(conexao, insertHist)
  
  #Inserindo os valores do histograma criado no banco de dados
  for (i in 1:length(frequencias)) {
    insertColuna <- sprintf(
      "INSERT INTO HistogramaColuna (fkHistograma, registroColuna) VALUES
      ((SELECT MAX(idHistograma) FROM Histograma), %f);",
      frequencias[i]
    )
    #exectuar o insert
    dbExecute(conexao, insertColuna)
  }
  dbDisconnect(conexao)
}
#-------------------------------------------------------------------------------
#Inserção dos dados no Banco - Fim