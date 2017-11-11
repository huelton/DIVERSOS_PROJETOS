var http = require('http');

var server = http.createServer(function(req, res){

    var categoria = req.url;

    if (categoria == '/tecnologia') {

    	res.end("<html><body>Noticias de Tecnologia</html></body>");

    } else if (categoria == '/viagem') {

    	res.end("<html><body>Noticias de Viagem</html></body>");

    } else if (categoria == '/esporte') {

    	res.end("<html><body>Noticias de Esporte</html></body>");

    } else{

    	res.end("<html><body> Portal de Noticias</html></body>");

    }


}).listen(3000);