Subasta Smart Contract - Trabajo Final Módulo 2

Descripción

Este proyecto implementa un contrato inteligente de subasta en Solidity, desplegado en la red de prueba Sepolia, cumpliendo con los requisitos del Trabajo Final del Módulo 2. El contrato permite a los usuarios ofertar por un artículo, manejar reembolsos parciales y totales (con una comisión del 2%), y extender el tiempo de la subasta si se realizan ofertas en los últimos 10 minutos.

Características del Contrato





Constructor: Inicializa la subasta con una duración de 7 días.



Función bid: Permite realizar ofertas válidas (mínimo 5% mayor que la oferta más alta). Extiende la subasta 10 minutos si la oferta se realiza cerca del final.



Función showWinner: Devuelve la dirección y monto del oferente ganador.



Función showOffers: Lista todas las ofertas realizadas.



Función partialRefund: Permite a los oferentes retirar fondos excedentes durante la subasta.



Función endAuction y refund: Finaliza la subasta y reembolsa a los no ganadores (menos 2% de comisión).



Eventos:





NewOffer: Emitido al realizar una nueva oferta.



AuctionEnded: Emitido al finalizar la subasta.



RefundProcessed: Emitido al procesar reembolsos totales.



PartialRefundProcessed: Emitido al procesar reembolsos parciales.



Seguridad:





Uso de modificadores (onlyOwner, isActive, hasEnded).



Prevención de reentrancy en transferencias de Ether.



Manejo robusto de errores.

Instrucciones de Despliegue





Configurar MetaMask:





Conectar a la red Sepolia.



Obtener Sepolia ETH desde Sepolia Faucet.



Compilar y Desplegar:





Usar Remix (remix.ethereum.org).



Pegar el código de Auction.sol.



Compilar con Solidity ^0.8.0.



Desplegar usando Injected Provider - MetaMask.



Verificar en Etherscan:





Usar el plugin de verificación de Remix.



Publicar el código fuente en Sepolia Etherscan.

Pruebas Realizadas

Se probaron todas las funcionalidades en Remix (JavaScript VM para pruebas de tiempo) y Sepolia:





Constructor: Verificado que startTime y stopTime se inicializan correctamente (7 días de duración).



Ofertas:





Oferta inicial de 0.1 ETH desde cuenta 1.



Oferta de 0.105 ETH desde cuenta 2 (5% mayor).



Intento de oferta inválida (0.1 ETH) falló correctamente.



Extensión de tiempo probada en JavaScript VM.



Ganador y Ofertas:





showWinner devolvió la cuenta 2 y 0.105 ETH.



showOffers listó todas las ofertas correctamente.



Reembolso Parcial:





Cuenta 1 ofertó 0.2 ETH adicional y retiró 0.1 ETH con partialRefund.



Evento PartialRefundProcessed confirmado.



Finalización y Reembolsos:





Subasta finalizada con endAuction (probado en JavaScript VM).



Reembolsos procesados con refund, aplicando 2% de comisión.



Evento RefundProcessed confirmado.



Eventos: Todos los eventos (NewOffer, AuctionEnded, etc.) verificados en los logs de Remix y Etherscan.

Notas Adicionales





Las pruebas de tiempo (extensión y finalización) se realizaron en JavaScript VM debido a la imposibilidad de avanzar el tiempo en Sepolia.



El contrato es seguro, con manejo de errores y prevención de reentrancy.

Contacto

Para dudas o comentarios, contactar a Roger Torres en rogertorres.pe@gmail.com o rogertorres.pe
