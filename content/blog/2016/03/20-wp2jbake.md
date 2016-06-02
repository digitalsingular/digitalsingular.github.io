title=Wordpress to JBake - Parseo
date=2016-03-20
type=post
tags=Java, JBake, Wordpress
status=published
~~~~~~
Pues ahora que ya tengo el constructor y construyo un objeto siempre que, al menos es coherente, toca parsear el xml para extraer los datos.
En Java, esencialmente hay tres formas de parsear xml, todas dentro de lo que se denomina Java XML Processing API, [JAXP](https://docs.oracle.com/javase/tutorial/jaxp/index.html):

1. [SAX](https://docs.oracle.com/javase/tutorial/jaxp/sax/index.html): La API originaria, orientada a eventos. Muy rápida y muy farragosa.
2. [DOM](https://docs.oracle.com/javase/tutorial/jaxp/dom/index.html): La API orientada a objetos, representa el XML como un árbol en memoria. Muy fácil de acceder, muy tragón de recursos (tienes todo el XML en memoria).
3. [StAX](https://docs.oracle.com/javase/tutorial/jaxp/stax/index.html): A partir del JDK 1.5 se encuentra disponible esta API que es un modelo mixto, se basa en un modelo de streaming (parecido a SAX) pero más sencillo de utilizar y además permite escribir.
