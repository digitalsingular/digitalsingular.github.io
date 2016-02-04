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

<#include "footer.ftl">
