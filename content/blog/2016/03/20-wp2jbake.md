title=Wordpress to JBake - Parseo
date=2016-03-20
type=post
tags=Java, JBake, Wordpress
status=published
~~~~~~
Pues ahora que ya tengo el constructor y construyo un objeto siempre que, al menos es coherente, toca parsear el xml para extraer los datos.
En Java, esencialmente hay tres formas de parsear xml, todas dentro de lo que se denomina Java XML Processing API, [JAXP](https://docs.oracle.com/javase/tutorial/jaxp/index.html):

1. [SAX](https://docs.oracle.com/javase/tutorial/jaxp/sax/index.html): La API originaria, orientada a eventos. Muy rápida, muy eficiente y muy farragosa. Técnicamente es una API de streaming mediante push, es decir, nosotros arrancamos el procesamiento del documento y la API empieza a funcionar mandándonos eventos conforme va encontrando elementos.
2. [DOM](https://docs.oracle.com/javase/tutorial/jaxp/dom/index.html): La API orientada a objetos, representa el XML como un árbol en memoria. Muy fácil de acceder, muy tragón de recursos. Técnicamente, se representa el árbol del DOM en memoria y listo, se puede acceder libremente, por ejemplo usando XPath.
3. [StAX](https://docs.oracle.com/javase/tutorial/jaxp/stax/index.html): A partir del JDK 1.5 se encuentra disponible esta API que es un modelo mixto, se basa en un modelo de streaming (parecido a SAX) pero más sencillo de utilizar y además permite escribir. Técnicamente se define como una API de streming mediante pull, es decir, que somos nosotros los que vamos indicanto los elementos que queremos acceder. Eso sí, al ser de streaming solo permite avanzar en el documento, es decir, no podemos ignorar el elemento 1, tratar el 2 y en función de este retroceder a tratar el 1.

En mi caso en particular, y dado que el modelo de "ir hacia delante" se adapta perfectamente al caso de uso (ya que simplemente estoy emparejando), pero tampoco necesito tantísima eficiencia ni tengo ganas de fastidiarme la vida, voy a utilizar StAX.

Pero lo primero, ahora que tengo que trabajar "en serio" es utilizar datos de verdad para las pruebas. Para eso hay dos opciones:

1. Guardo un XML de pruebas en forma de un String en un archivo .java y lo leo de ahí.
2. Guardo un archivo XML como tal.

Pues como que la primera opción es una tontería, he optado por la segunda. He sacado la exportación de datos que proporciona Wordpress y he dejado unos cuantos posts que sean más o menos representativos y listo. Lo guardo en _src/resources/wp-source.xml_. Antes de seguir, ya no tiene sentido que los tests sigan usando el _pom.xml_ para las pruebas, así que lo cambio y lo lanzo. Todo en verde, como cabía esperar.

Ahora bien, ya tengo mi objeto de la clase Wp2JBake creado con el origen y el destino debidamente especificado, ¿como arranco el procesamiento? Hay que tener en cuenta que realmente el método de proceso no tiene por qué devolver nada, ya que el resultado efectivo de la salida es una estructura de archivos con el resultado de la conversión.
Sin embargo, creo que es "gratis" devolver los elementos que se han generado y así se posibilita poder comprobar el resultado de la generación.

Así que primero el test:

```prettyprint
@Test
public void processEmptyXML() {
    sut = new Wp2JBake("src/test/resources/empty.xml", "src/test/destination");
    Set<File> markdowns = sut.generateJBakeMarkdown();
    assertThat(markdowns, is(empty()));
    File destination = new File("destination");
    destination.delete();
}
```

Obviamente, esta en rojo, allá va la implementación:

```prettyprint
public Set<File> generateJBakeMarkdown() {
    return new HashSet<File>();
}
```

Y aquí, ya voy devolviendo un Set (porque todos los elementos serán distintos, cada archivo representa un post y cada post es único) y uso uno no ordenado, porque en realidad me dá igual el orden de iteración, ya que [como decidí](../02/04-wp2jbake.html) los archivos vendrán ordenados por su ruta, es decir, si existen, por definición estan ordenados.

Vale, y ahora, test de verdad:

```prettyprint
@Test
public void processXML() {
    sut = new Wp2JBake("src/test/resources/wp-source.xml", "src/test/destination");
    Set<File> markdowns = sut.generateJBakeMarkdown();
    assertThat(markdowns, is(not(empty())));
    for (File markdown: markdowns) {
        assertThat(markdown.exists(), is(true));
    }
    File destination = new File("destination");
    destination.delete();
}
```

Ahora tengo que modificar el método _generateJBakeMarkdown_ para que genere los archivos Markdown. En un principio hay dos formas de hacer ésto:

1. Parseo el XML, genero una estructura de datos en memoria (una representación de los posts, vaya) y después la recorro y la paso a los archivos markdown. Desventaja, que para eso para qué demonios uso StAX y el streaming, si voy a comer memoria uso DOM y listo.
2. Parseo el XML y cada vez que se detecte un item (un post) lo voy escribiendo dinámicamente. Creo que esta opción es más complicada, pero más ligera.

Vamos a por 2, para ello leeré el XML y lo volcaré... pero un momento, una cosa es saber leer el XML y otra escribir el Markdown, es decir, que mi clase lectora (_Wp2JBake_) a su vez debe comunicarse (usar) otra para escribir (_MdWriter_).
Pensando un poco más sobre esta clase _MdWriter_... debería recibir como parámetro en su constructor el destino de las escrituras y eso me lleva a pensar, que realmente es a ella a la que le corresponde comprobar si es un destino legal, es decir, que el constructor de _Wp2JBake_ ahora quedaría así (también he aprovechado y _origin_ lo he guardado en un atributo de la clase):

```prettyprint
public Wp2JBake(String origin, String destination) {
    if (StringUtils.isEmpty(origin) || !existsOrigin(origin)) {
        throw new IllegalArgumentException("Origin is not a valid file");
    } else {
        this.origin = origin;
    }
    this.mdWriter = new MdWriter(destination);
}
```

Mientras que _MdWriter_ sería así:

```prettyprint
public class MdWriter {

    private File destinationFolder;

    public MdWriter(String destination) {
        if (StringUtils.isEmpty(destination) || !isWritable(destination)) {
            throw new IllegalArgumentException("Destination is not a valid folder");
        } else {
            destinationFolder = new File(destination);
        }
    }

    private boolean isWritable(String destination) {
        File destinationFolder = new File(destination);
        if (destinationFolder.exists()) {
            return destinationFolder.canWrite();
        } else {
            return isWritableDestinationParent(destinationFolder);
        }
    }

    private boolean isWritableDestinationParent(File destinationFolder) {
        File destinationParent = getDestinationParent(destinationFolder);
        return destinationParent.canWrite();
    }

    private File getDestinationParent(File destinationFolder) {
        String parentPath = destinationFolder.getParent();
        if (parentPath == null) {
            parentPath = "";
        }
        return new File(parentPath);
    }
}
```

Por cierto que la teoría TDDista dice que esto no debería hacerse, que primero hay que pasar el test y después ponerse a refactorizar y tal... Hombre, yo eso no lo comparto tanto, creo que esta bien ir pensando un poco las cosas. Además, como ya tengo hechos los tests, los puedo volver a ejecutar para ver que no me he cargado nada.
Que hablando de las pruebas, ahora tengo que crear las pruebas propias de esta nueva clase y llevarme todas las encargadas de testear la corrección del directorio destino a esa clase. Al separarlo además ya no tengo que diferenciar entre los tipos de excepción (era muy cantoso que estaba pasando del Single Responsability) y el código queda mucho más limpio:

```prettyprint
public class Wp2JBakeTests {

    private Wp2JBake sut;

    @Test(expected = IllegalArgumentException.class)
    public void buildWithoutParameters() {
        sut = new Wp2JBake(null, null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void buildWithoutOrigin() {
        sut = new Wp2JBake(null, "foo");

    }

    @Test(expected = IllegalArgumentException.class)
    public void buildWithEmptyOrigin() {
        sut = new Wp2JBake("", "");
    }

    @Test(expected = IllegalArgumentException.class)
    public void buildWithInvalidOrigin() {
        sut = new Wp2JBake("foo", "");
    }

    @Test
    public void buildWithValidParameters() {
        sut = new Wp2JBake("src/test/resources/wp-source.xml", "src/test/destination");
    }

    @Test
    public void processEmptyXML() {
        sut = new Wp2JBake("src/test/resources/empty.xml", "src/test/destination");
        Set<File> markdowns = sut.generateJBakeMarkdown();
        assertThat(markdowns, is(empty()));
    }

    @Test
    public void processXML() {
        sut = new Wp2JBake("src/test/resources/wp-source.xml", "src/test/destination");
        Set<File> markdowns = sut.generateJBakeMarkdown();
        assertThat(markdowns, is(not(empty())));
        for (File markdown: markdowns) {
            assertThat(markdown.exists(), is(true));
        }
        File destination = new File("destination");
        destination.delete();
    }
}

public class MdWriterTest {

    private MdWriter sut;

    @Test(expected = IllegalArgumentException.class)
    public void writerWithoutDestination() {
        sut = new MdWriter(null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void writerWithEmptyDestination() {
        sut = new MdWriter("");
    }

    @Test(expected = IllegalArgumentException.class)
    public void writerWithNonWritableDestination() {
        File destination = new File("destination");
        destination.mkdir();
        destination.deleteOnExit();
        destination.setReadOnly();
        sut = new MdWriter(destination.getAbsolutePath());
    }

    @Test(expected = IllegalArgumentException.class)
    public void writerWithNonWritableDestinationParent() {
        File destinationParent = new File("destinationParent");
        destinationParent.mkdir();
        destinationParent.deleteOnExit();
        destinationParent.setReadOnly();
        sut = new MdWriter(destinationParent.getAbsolutePath() + File.separator + "destination");
    }
}
```

Bueno, pues ahora tengo que leer el XML e ir cargando los Strings que el escritor se encargará de volcar a disco... muy bien. Lo primer es crear la factoría de eventos. Por cierto, menuda bazofia el tutorial oficial de Oracle, menos mal que [Lars Vogel](http://www.vogella.com/tutorials/JavaXML/article.html)  tiene un grandísimo tutorial (danke schön Lars!):

```prettyprint
public Set<File> generateJBakeMarkdown() {
        XMLEventReader eventReader = getEventReader();
        return new HashSet<File>();
    }

    private XMLEventReader getEventReader() {
        XMLInputFactory inputFactory = XMLInputFactory.newInstance();
        InputStream in = null;
        XMLEventReader eventReader = null;
        try {
            in = new FileInputStream(origin);
            eventReader = inputFactory.createXMLEventReader(in);
        } catch (FileNotFoundException e) {
            throw new IllegalStateException("Could not find origin file: " + e.getMessage());
        } catch (XMLStreamException e) {
            throw new IllegalStateException("Could not read origin file: " + e.getMessage());
        }
        return eventReader;
    }
```

He optado por lanzar un IllegalStateException si ocurre alguna de las excepciones, ya que eso no debería ocurrir y a lo que lleva es exactamente a eso, un estado ilegal del programa :)
Hmmm... por otra parte, tengo la prueba con el XML vacío, pero ahora que lo pienso ¡¡¡no tengo ninguna con un XML inválido!!! Me creo un XML _invalid.xml_ que contiene solo la cabecera con un número de versión que no existe:

```prettyprint
<?xml version="-1.0" encoding="utf-8"?>
```

Y su test:

```prettyprint
@Test(expected = IllegalStateException.class)
public void processInvalidXML() {
    sut = new Wp2JBake("src/test/resources/invalid.xml", "src/test/destination");
    Set<File> markdowns = sut.generateJBakeMarkdown();
}
```

Me esta empezando a parecer que la lectura también debería ir en otra clase y _Wp2JBake_ tan solo orquestrar la lectura con la escritura... pero bueno, ya iremos viendo de momento sigo, así. Toca tratar los eventos. El tutorial hace un típico bucle while con el eventReader que implementa _Iterator_, pero claro, el tutorial es antiguo, al fin y al cabo y pensándolo bien... yo lo que quiero hacer es un filter y un collect, es decir, que puedo usar la API de Streams de Java 8. La única historia es convertir el _XMLEventReader_ a un _Stream<XMLEvent>_, pero eso es relativamente fácil:

```prettyprint
public Set<File> generateJBakeMarkdown() {
    XMLEventReader eventReader = getEventReader();
    Iterable<XMLEvent> eventsIterable = () -> eventReader;
    Stream<XMLEvent> xmlEvents = StreamSupport.stream(eventsIterable.spliterator(), false);
    return new HashSet<File>();
}
```

Bueno, pues después de echar hora y pico probando con filter, map, flatmap etc, hay un problema, y es que StAX entiende todo el documento secuencialmente, con lo cual no puedo hacer un filter y quedarme solo con los elemntos de tipo _item_ y después acceder a los elementos que contienen estos, porque un elemento esta suelto, así que nada, toca iteradores y bucles for de toda la vida. Para que sea más entendible (y orientado a objetos), me voy a crear una clase _Post_ para ir guardando los resultados y después volcarlos al archivo pertinente.
Esta clase la monto con una API fluida para que la construcción me sea más sencilla y los correspondientes getters:

```prettyprint
public class Post {
    private String title;

    private LocalDate publishingDate;

    private Set<String> tags = new TreeSet<>();

    private String content;

    public Post () {

    }

    public Post withTitle(String title) {
        this.title = title;
        return this;
    }

    public Post withPublishingDate(LocalDate publishingDate) {
        this.publishingDate = publishingDate;
        return this;
    }

    public Post withTag(String tag) {
        this.tags.add(tag);
        return this;
    }

    public Post withContent(String content) {
        this.content = content;
        return this;
    }

    public String getTitle() {
        return title;
    }

    public LocalDate getPublishingDate() {
        return publishingDate;
    }

    public Set<String> getTags() {
        return tags;
    }

    public String getContent() {
        return content;
    }
}
```

En fín, ya han pasado como tres horas y el test sigue sin funcionar... me deprimo...
Sigo con el for, la estrategia es muy sencilla, si detecto un elemento _item_, creo un nuevo _Post_ y conforme vaya detectando los elementos _title_, _pubDate_, _category_ y _content_ voy invocando a los métodos _with*_ del _Post_. En el momento que detecte el cierre del _item_, escribo a disco:

```prettyprint
public Set<File> generateJBakeMarkdown() {
    XMLEventReader eventReader = getEventReader();
    Iterable<XMLEvent> eventsIterable = () -> eventReader;
    Stream<XMLEvent> xmlEvents = StreamSupport.stream(eventsIterable.spliterator(), false);
    return new HashSet<File>();
}
```
