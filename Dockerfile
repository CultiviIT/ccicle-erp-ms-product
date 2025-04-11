# Etapa 1: Usar uma imagem Maven com OpenJDK
FROM maven:3-amazoncorretto-21 AS builder
LABEL authors="cultivi_it"

# Definir o diretório de trabalho dentro do container
WORKDIR /app

# Copiar o arquivo pom.xml e dependências do Maven
COPY pom.xml .

# Baixar dependências do Maven
RUN mvn dependency:go-offline

# Copiar o código-fonte
COPY src /app/src

# Compilar o projeto Java (gerar o arquivo .jar)
RUN mvn clean package -DskipTests

# Etapa 2: Criar uma imagem mais enxuta para rodar a aplicação
FROM openjdk:21-jdk-slim

# Definir o diretório de trabalho
WORKDIR /app

# Copiar o .jar gerado pela etapa de build
COPY --from=builder /app/target/product-0.0.1-SNAPSHOT.jar /app/app.jar

# Defina uma variável de ambiente baseada no argumento BUILD_ENV
ARG BUILD_ENV=dev  # O padrão será 'dev' caso não seja especificado

# Use essa variável para configurar o perfil do Spring ou outra variável de configuração
ENV SPRING_PROFILES_ACTIVE=$BUILD_ENV

# Expor a porta que o microsserviço vai rodar
EXPOSE 8080

# Comando para rodar o microsserviço
CMD ["java", "-jar", "app.jar"]
