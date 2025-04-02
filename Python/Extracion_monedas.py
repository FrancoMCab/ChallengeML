#Realizamos el import de las librerias a utilizar.

import requests
import csv
import xml.etree.ElementTree as ET
from datetime import datetime, timezone

# Metodo para la obtencion de las combinaciones posibles habilitadas.
def obtener_combinaciones_disponibles():
    url = "https://economia.awesomeapi.com.br/xml/available"
    response = requests.get(url)
    if response.status_code == 200:
        try:
            root = ET.fromstring(response.text)
            monedas = [moneda.tag for moneda in root]
            return monedas
        except ET.ParseError:
            print("Error al parsear la respuesta XML")
            return []
    else:
        print(f"Error al obtener lista de combinaciones: {response.status_code}")
        return []

# Metodo que realiza la consulta a la API AwesomeAPI para obtener las cotizaciones de las monedas.
def obtener_cotizaciones(monedas):
    url = f"https://economia.awesomeapi.com.br/json/last/{','.join(monedas)}" #La API indica enviar las monedas que se quiere solicitar de la siguiente manera Ej: USD-BRL,EUR-BRL,BTC-BRL.
    response = requests.get(url)
    if response.status_code == 200:
        try:
            datos = response.json()
            if not datos:
                print("Respuesta vacía de la API")
                return None
            return datos
        except ValueError:
            print("Error al decodificar la respuesta JSON")
            return None
    else:
        print(f"Error al obtener cotizaciones: {response.status_code}")
        return None

# Metodo para la transformacion de los datos.
def transformar_datos(datos):
    cotizaciones = []
    fecha_carga = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    for clave, valor in datos.items():
        try:
            moneda_base = valor.get("code", "Desconocido")
            moneda_destino = valor.get("codein", "Desconocido")
            valor_compra = float(valor.get("bid", 0))
            valor_venta = float(valor.get("ask", 0))
            timestamp = int(valor.get("timestamp", 0))
            fecha_hora = datetime.fromtimestamp(timestamp, tz=timezone.utc).strftime("%Y-%m-%d %H:%M:%S")
            
            if valor_compra == 0 or valor_venta == 0:
                print(f"Advertencia valores de cotización no válidos para {moneda_base}-{moneda_destino}")
                continue
            
            cotizacion = {
                "moneda_base": moneda_base,
                "moneda_destino": moneda_destino,
                "valor_compra": valor_compra,
                "valor_venta": valor_venta,
                "fecha_hora": fecha_hora,
                "fecha_carga": fecha_carga
            }
            cotizaciones.append(cotizacion)
        except (ValueError, TypeError) as e:
            print(f"Error al procesar datos de {clave}: {e}")
    return cotizaciones

# Metodo que efectua el guardado de los datos en forma de CSV.
def guardar_csv(cotizaciones):
    if not cotizaciones:
        print("No hay datos para guardar en el archivo CSV.")
        return
    
    fecha_actual = datetime.now().strftime("%Y-%m-%d")
    archivo = f"datos_monedas_{fecha_actual}.csv"
    
    with open(archivo, mode="w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=["moneda_base", "moneda_destino", "valor_compra", "valor_venta", "fecha_hora", "fecha_carga"])
        writer.writeheader()
        writer.writerows(cotizaciones)
    print(f"Datos guardados en {archivo}")


if __name__ == "__main__":
    monedas = obtener_combinaciones_disponibles()
    datos = obtener_cotizaciones(monedas)
    if datos:
        cotizaciones = transformar_datos(datos)
        guardar_csv(cotizaciones)