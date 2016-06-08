title=Wordpress to JBake - Integración
date=2016-06-08
type=post
tags=Java, JBake, Wordpress
status=published
~~~~~~
Realmente las pruebas de integración ya casi estan hechas y son muy sencillas ya que se trata de interactuar en todo caso con la clase principal _Wp2JBake_, usando donde sea necesario el archivo de pruebas.
Lo único interesante van a ser los asserts para comprobar que todo es correcto.
En un principio, las pruebas definidas pasan sin mayor problema, pero en primer lugar, hay que preguntarse si se estan exportando todos los posts o solo aquellos que estan publicados, es decir, el test usando el wp-source.xml sería el siguiente:

```prettyprint
@Test
public void processXML() {
    sut = new Wp2JBake(POSTS_SOURCE, DESTINATION);
    Set<File> markdowns = sut.generateJBakeMarkdown();
    assertThat(markdowns.size(), is(5));
    assertThat(markdowns, is(not(empty())));
    for (File markdown: markdowns) {
        assertThat(markdown.exists(), is(true));
    }
}
```

Y este test falla porque markdowns tiene 7 elementos. Esto es así porque hay 2 elementos que en _pubDate_ tienen como año el -0001, lo cual significa que es un borrador, así que hay que corregir la implementación. En un principio lo iba a poner en el _MdWriter_, pero realmente esta clase tan solo tiene que conocer los detalles de la escritura, no cuales elementos se deben escribir y cuales no. En _WpParser_ tampoco tiene sentido por motivos similares, esta clase solo lee. Pensándolo de otra forma, ¿qué clase es la que decide cómo se lee y cómo se escribe? Pues _Wp2JBake_, más concretamente en el callback _postRead_, así que ahí es el sitio en el que decidir si el post se exporta o no:

```prettyprint
public class Wp2JBake {

    public static final int DRAFT_YEAR = 2;
    private WpReader wpReader;

    private MdWriter mdWriter;

    private HashSet<File> exportResult;

    public Wp2JBake(String origin, String destination) {
        this.wpReader = new WpReader(origin);
        this.mdWriter = new MdWriter(destination);
    }

    public Set<File> generateJBakeMarkdown() {
        exportResult = new HashSet<>();
        wpReader.readPosts(this);
        return exportResult;
    }

    public void postRead(Post post) {
        if (!postIsDraft(post)) {
            exportResult.add(mdWriter.write(post));
        }
    }

    private boolean postIsDraft(Post post) {
        Calendar postCalendar = Calendar.getInstance();
        postCalendar.setTime(post.getPublishingDate());
        return (postCalendar.get(Calendar.YEAR) == DRAFT_YEAR);
    }
}
```

Lo de la fecha es un poco... por algún motivo, al hacer el parseo de la fecha, decide que el año -0001 lo va a convertir en 2, eah... pues nada, así se queda porque tanto me dá un valor como otro. Y ahora ya pasa el test. Bueno, pues lo siguiente es comprobar qué pasa con las etiquetas `<pre`>.
El problema que hay realmente con esas etiquetas no es del conversor ni nada, sino que al migrar a JBake tengo que pasarlas a prettyprint para que las entienda, puedo tener el mismo problema con otras etiquetas, que las tenga que convertir por un motivo de formato, que no queden muy feas en el nuevo diseño del blog.
Pero empiezo por las `<pre`>. Esto sí que es claramente algo a tratar en _MdWriter_, el plugin de Wordpress para colorear el código utilizaba distintas marcas como `<pre lang=xml`> o `<pre lang=java`> por tanto hay que sustituir en content todo lo que sea `<pre *`> por `````prettyprint. Ahora que lo pienso, _MdWriter_ debe saber como escribir, pero desde luego no es responsabilidad suya saber como traducir, así que sale una clase nueva _MdTranslator_ con un único método, _translate_. Y repasando el método de escritura del post, también es responsabilidad suya el convertir los tags y la fecha, ahora se ve claramente, así que harán falta más métodos.

Habrá que crear sus correspondientes test:

```prettyprint
public class MdTranslatorTest {

    public static final String TAG_1 = "tag 1";
    public static final String TAG_2 = "tag 2";
    public static final String TEST_DATE = "2016-01-01";
    public static final String TEST_CONTENT = "content";
    public static final String TEST_PRE_CONTENT = "<pre lang=\"java\"> contenido java </pre>";
    public static final String TEST_PRE_RESULT = "\n```prettyprint\n contenido java \n```\n";

    private MdTranslator sut = new MdTranslator();

    @Test
    public void translateDate() throws Exception {
        String dateAsString = TEST_DATE;
        SimpleDateFormat formatter = new SimpleDateFormat(MdTranslator.POST_DATE_FORMAT);
        Date date = formatter.parse(dateAsString);
        String translatedDate = sut.translateDate(date);
        assertThat(translatedDate, is(dateAsString));
    }

    @Test
    public void translateTags() {
        List<String> tags = new ArrayList<>(2);
        tags.add(TAG_1);
        tags.add(TAG_2);
        String translatedTags = sut.translateTags(tags);
        assertThat(translatedTags, is(TAG_1 + MdTranslator.TAG_DELIMITER + TAG_2));
    }

    @Test
    public void translateContent() {
        String translatedContent = sut.translateContent(TEST_CONTENT);
        assertThat(translatedContent, is(TEST_CONTENT));
    }

    @Test
    public void translateContentWithPreWithLanguage() {
        String translatedContent = sut.translateContent(TEST_PRE_CONTENT);
        assertThat(translatedContent, is(TEST_PRE_RESULT));
    }
}
```

Todos funcionan menos el último, claro, hay que cambiar la implementación del _translateContent_:

```prettyprint
public class MdTranslator {

    public static final String POST_DATE_FORMAT = "yyyy-MM-dd";
    public static final String TAG_DELIMITER = ",";


    public String translateDate(Date dateToTranslate) {
        DateFormat formatter = new SimpleDateFormat(POST_DATE_FORMAT);
        return formatter.format(dateToTranslate);
    }

    public String translateTags(Collection<String> tagsToTranslate) {
        return tagsToTranslate.stream().map(Object::toString).collect(Collectors.joining(TAG_DELIMITER));
    }

    public String translateContent(String contentToTranslate) {
        String translatedContent = translatePre(contentToTranslate);
        return translatedContent;
    }

    private String translatePre(String contentToTranslate) {
        String contentWithoutStartingPre = contentToTranslate.replaceAll("<pre[^>]*>", "\n```prettyprint\n");
        String contentWithoutEndingPre = contentWithoutStartingPre.replaceAll("</pre>", "\n```\n");
        return contentWithoutEndingPre;
    }
}
```

Con ésto ya bastaría, pero mirando el estilo, hay bastantes etiquetas `<h1`> etc... para dar formato. Estas etiquetas no pegan nada en el diseño nuevo de la página, ya que el titular del post es un `<h4`>, así que el `<h1`> debería ser el `<h5`> y sucesivamente... vamos a ello.
