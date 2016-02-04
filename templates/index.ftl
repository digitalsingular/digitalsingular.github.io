<#include "header.ftl">
<div class="col s2 hide-on-small-only">
	<div class="card hoverable">
		<div class="card-content">
			<span class="card-title"><h5 class="light-blue-text text-darken-1">Tags</h5></span>
			<ul>
		<#list alltags as tag>
			<li><a href="${content.rootpath}tags/${tag}.html">${tag}</a></li>
		</#list>
	</ul>
	</div>
</div>
</div>
<div class="col s12 m10">
	<#list posts as post>
  		<#if (post.status == "published")>
			<div class="card hoverable">
				<div class="card-content">
	  			<span class="card-title"><a href="${post.uri}"><h4><#escape x as x?xml>${post.title}</#escape></h4></a></span>
					<div class="section">
	  			<p>${post.date?string("dd MMMM yyyy")}</p>
					</div>
					<div class="section">
	  			<p class="flow-text">${post.body}</p>
					</div>
				</div>
				<div class="card-action">
					<a href="${post.uri}"><#escape x as x?xml>Leer</#escape></a>
				</div>
			</div>
  		</#if>
  	</#list>
	<div class="card hoverable">
		<div class="card-content">
			<span class="card-title"><a href="${content.rootpath}${config.archive_file}">Archivo</a></span>
			<p>Consulta todos los posts</p>
		</div>
	</div>
<#include "footer.ftl">
