## MeliApp Challenge

![demo_gif](ezgif.com-gif-maker.gif)

## Arquitectura

Para el desarrollo de este ejercicio escogí el patrón de arquitectura **MVVM (Model, View, ViewModel)** en combinación con las bondades de la programación funcional reactiva con **RxSwift** para la comunicación entre el View y el ViewModel. Con respecto a los providers y la capa de servicio también utilicé closures para demostrar otra forma de implementación de la comunicación entre las distintas capas. 

![MVVM](https://assets.alexandria.raywenderlich.com/books/rxs/images/0bac92f0c3f01a900078203549ed6255699df19761dd15f0578ffb981948c302/original.png)

"diagrama y estructura del proyecto (capturas)"

## Funcionalidades / requerimientos

- [x] Búsqueda de productos
- [x] Visualización de resultados de la búsqueda (listado paginado)
- [x] Visualización de detalles de un producto
- [x] Marcar producto como favorito
- [x] Ver producto en la página de Mercadolibre (Comprar)
- [] Listado de favoritos (WIP)

## Librerias de 3ros

| **Pod** | **Version** | **Descripción** |
|:---:|:---:|:---:|
| **RxSwift** |![Badge w/ Version](https://img.shields.io/cocoapods/v/RxSwift)| [something] |
| **RxCocoa** |![Badge w/ Version](https://img.shields.io/cocoapods/v/RxCocoa)| [something] |

## Pruebas unitarias

WIP

## Recursos de la API

| **URL Base** | **Path** | **Método** | **Uso** | **Clase Modelo** |
|---|---|:---:|---|:---:|
| **api.mercadolibre.com** | /items/**{{itemID}}** | GET | Obtener detalles de un item/publicación por ID | **ItemModel** |
| **api.mercadolibre.com** | /items/**{{itemID}}**/descripcion | GET | Obtener descripción de un item/publicación | **ItemDescriptionModel** |
| **api.mercadolibre.com** | /sites/**{{siteID}}**/search?q=**{{itemID}}** | GET | Obtener items de una consulta de búsqueda | **SearchResultModel** |

## Especificaciones Entorno

| **Spec** | **Version** | **Descripción** |
|---|:---:|---|
| ![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white) | 5.0 | como lenguaje de programación. |
| ![Cocoapods](https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=macos&logoColor=F0F0F0) | 12.0 | macOS |
| ![Xcode](https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white) | 13.0 | como entorno de desarrollo. |
| ![IOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white) | 15.0 | Mínima compatible |
| ![Mac OS](https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=macos&logoColor=F0F0F0) | 12.0 | macOS |
