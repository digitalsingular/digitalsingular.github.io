<#include "header.ftl">
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
