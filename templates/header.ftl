<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="utf-8"/>
    <title><#if (content.title)??><#escape x as x?xml>${content.title}</#escape><#else>Digital Singular</#if></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Digital Singular, sobre software>
    <meta name="author" content="Agustín Ventura">
    <meta name="keywords" content="Software, Desarrollo, Programación">
    <meta name="generator" content="JBake">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/css/materialize.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/js/materialize.min.js"></script>
    <link rel="stylesheet" href="<#if (content.rootpath)??>${content.rootpath}<#else></#if>css/digitalsingular.css"/>
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <script src="https://kit.fontawesome.com/64e1074656.js" crossorigin="anonymous"></script>
       <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500;1,600;1,700&display=swap" rel="stylesheet"> 
  </head>
  <body>
    <header>
        <#if (!(numberOfPages??) || (numberOfPages == 0))>
          <#include "menu.ftl">
        </#if>
    </header>
