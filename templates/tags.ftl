<#include "header.ftl">

	<h2 class="light-blue-text text-darken-1">
		Tag: ${tag}
	</h2>

		<#list tag_posts as post>
		<#if (last_month)??>
			<#if post.date?string("MMMM yyyy") != last_month>
			</div>
		</div>
		<div class="card hoverable">
			<div class="card-content">
				<span class="card-title">
					<h4>${post.date?string("MMMM yyyy")}</h4>
				</span>
			</#if>
		<#else>
		<div class="card hoverable">
			<div class="card-content">
				<span class="card-title">
					<h4>${post.date?string("MMMM yyyy")}</h4>
				</span>
		</#if>

		${post.date?string("dd")} - <a href="${content.rootpath}${post.uri}">${post.title}</a><br/>
		<#assign last_month = post.date?string("MMMM yyyy")>
		</#list>
	</div>

<#include "footer.ftl">
