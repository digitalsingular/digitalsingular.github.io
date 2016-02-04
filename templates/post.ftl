<#include "header.ftl">
<div class="col s12">
<div class="card hoverable">
	<div class="card-content">
		<span class="card-title">
			<h4 class="light-blue-text text-darken-1"><#escape x as x?xml>${content.title}</#escape></h4>
		</span>
		<div class="section">
			<p>${content.date?string("dd MMMM yyyy")}</p>
		</div>
		<div class="section">
			<p>${content.body}</p>
		</div>
	</div>
</div>
<hr />
<div id="disqus_thread"></div>
<script>
    var disqus_config = function () {
        this.page.url = '${config.site_host}/${content.uri}';
        this.page.identifier = '${content.uri}';
    };
    (function() {
        var d = document, s = d.createElement('script');
        s.src = '//aguasnegras.disqus.com/embed.js';
        s.setAttribute('data-timestamp', +new Date());
        (d.head || d.body).appendChild(s);
    })();
</script>
<noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript" rel="nofollow">comments powered by Disqus.</a></noscript>
<#include "footer.ftl">
