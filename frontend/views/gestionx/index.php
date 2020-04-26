<?php
use frontend\assets\GestionxAsset;

$this->title = "GestionX - Administrá tu negocio";

GestionxAsset::register($this);
$this->registerJs("Gestionx.init();");
?>

<header class="container">
	<div class="responsive intro-container">
		<div class="app-icon">
			<img alt="Logo" src="img/logo-gestionx.svg">
			<p>GestionX</p>
		</div>
		<div class="intro">
			<h2><strong>GestionX</strong></h2>
			Es un software en la nube, con soporte para
			facturación electrónica de AFIP, que te permite
			administrar tu negocio.
		</div>
	</div>
	<div class="responsive iphone">
		<div class="iphone-screenshot">
			<img src="img/gestionx.png" alt="App screenshot">
		</div>
		<img class="iphone-mask" src="img/iphone.png">
	</div>
</header>
<section class="container">
<h4>Suscribirse al servicio</h4>
<div id="gestionx" v-cloak>
    <div v-for="plan in planes">
        <div>{{ plan.Plan }}</div>
        <div>{{ plan.Precio }} USD</div>
    </div>
</div>
</section>
<!--footer class="container footer">
	<div class="sep"></div>
	<p class="responsive credit">Made with ♥ by <a href="https://twitter.com/twitterusername">Your Name</a></p>
	<div class="responsive contact">
		<a href="mailto:youremail@gmail.com?subject=App Name">Support</a>
		<a href="">Press Kit</a>
	</div>
</!--footer -->
<script>
	(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	})(window,document,'script','//www.google-analytics.com/analytics.js','ga');
	ga('create', 'UA-XXXXXXXX-XX', 'auto');
	ga('send', 'pageview');
</script>
