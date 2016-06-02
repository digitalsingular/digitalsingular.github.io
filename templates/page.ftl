<#include "header.ftl">
<div class="container">
<div class="row">
<div class="col s12">
			<h4 class="light-blue-text text-darken-1"><#escape x as x?xml>${content.title}</#escape></h4>
			<div class="section">
				<p>${content.date?string("dd MMMM yyyy")}</p>
			</div>
			<div class="section">
				<p>${content.body}</p>
			</div>
</div>
</div>
</div>
<#include "footer.ftl">
