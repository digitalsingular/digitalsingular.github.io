<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="utf-8"/>
    <title><#if (content.title)??><#escape x as x?xml>${content.title}</#escape><#else>AguasNegras</#if></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="AguasNegras, tecnología, programación y Java">
    <meta name="author" content="Agustín Ventura">
    <meta name="keywords" content="Programación, Java">
    <meta name="generator" content="JBake">
    <!--Import Google Icon Font-->
     <link href="http://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <!-- Compiled and minified CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/materialize/0.97.5/css/materialize.min.css">
    <!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="<#if (content.rootpath)??>${content.rootpath}<#else></#if>js/html5shiv.min.js"></script>
    <![endif]-->
    <link rel="shortcut icon" href="<#if (content.rootpath)??>${content.rootpath}<#else></#if>favicon.ico">
  </head>
  <body>
    <header>
      	<#include "menu.ftl">
    </header>
    <div class="container">
      <div class="row">
        <div class="col s2">
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
        <div class="col s10">
