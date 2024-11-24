install.packages("httr")
library(httr)
install.packages("here")
library(here)
install.packages("rmarkdown")
library(rmarkdown)


# Executar script do histograma da dashboard ADM
source(here("etl-histogram-servguard.R"))

#Renderizar o arquivo RMarkdown
render(
  input = here("relatorio_semanal.Rmd"),
  output_file = paste0("relatorio_semanal_", format(Sys.Date(), "%d-%m-%Y"), ".html")
)

# Token de autenticação do Slack
slack_token <- "xoxb-seu-token-aqui"

# ID do canal onde o arquivo será enviado
channel_id <- "C0123ABCDE"

file_path <- here(paste0("relatorio_semanal_", format(Sys.Date(), "%d-%m-%Y"), ".html"))

# Fazer o upload do arquivo
response <- POST(
  # Passar link do canal:
  url = "https://slack.com/api/files.upload",
  add_headers(Authorization = paste("Bearer", slack_token)),
  body = list(
    channels = channel_id,
    file = upload_file(file_path),
    initial_comment = "Segue o relatório semanal!"
  ),
  encode = "multipart"
)

# Verificar o status da solicitação
if (http_status(response)$category == "Success") {
  message("Arquivo enviado com sucesso!")
} else {
  message("Erro ao enviar o arquivo: ", content(response, "text"))
}

