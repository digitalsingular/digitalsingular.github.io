    <footer class="page-footer light-blue darken-3">
      <div class="container">
        <div class="row">
         <div class="col s5">
			<h5><a href="${content.rootpath}${config.archive_file}" class="white-text">Archivo</a></h5>
			<p><a href="${content.rootpath}${config.archive_file}" class="white-text">Todos los posts</a></p>
	    </div>
	    <div class="col s5">
            <h5 class="white-text">Tags</h5>
		        <#list alltags as tag>
			    <a href="${content.rootpath}tags/${tag}.html"><div class="chip">${tag}</div></a>
		        </#list>
	    </div>
        <div class="col s2 right-align">
            <a href="http://twitter.com/agustinventura" target="_blank" class="social-link white-text" ><i class="fa  fa-twitter  fa-3x" title="Twitter" aria-hidden="true"></i></a>
            <a href="http://github.com/agustinventura" target="_blank" class="social-link white-text"><i class="fa  fa-github  fa-3x" title="Github" aria-hidden="true"></i></a>
            <a href="https://www.linkedin.com/in/agustinventura" target="_blank" class="social-link white-text"><i class="fa  fa-linkedin  fa-3x" title="LinkedIn" aria-hidden="true"></i></a>
        </div>
      </div>
      </div>
      </div>
      <div class="footer-copyright">
            <div class="container">
        <p class="center-align">&copy; 2016 | Mixed with <a class="footer-link white-text" href="http://materializecss.com/" target="_blank">Materialize</a> | Baked with <a <a class="footer-link white-text" href="http://jbake.org">JBake</a></p>
            </div>
          </div>
    </footer>

    <script async src="//cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js"></script>
		<script async src="//code.jquery.com/jquery-2.1.4.min.js"></script>
    <script async src="//cdnjs.cloudflare.com/ajax/libs/materialize/0.97.5/js/materialize.min.js"></script>
  </body>
</html>
