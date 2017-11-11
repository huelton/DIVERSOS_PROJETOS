module.exports.noticias = function(application, req, res){

    var connection = application.config.dbConnection();
    var noticiasModel = new application.app.models.NoticiasDAO(connection); //chamada do modelo pela variavel

    //utilizando o metodo
    noticiasModel.getNoticias(function(error, result){
        res.render("noticias/noticias", {noticias : result});

    });	
}

module.exports.noticia = function(application, req, res){

    var connection = application.config.dbConnection();
    var noticiasModel = new application.app.models.NoticiasDAO(connection); //chamada do modelo pela variavel

    var id_noticia = req.query;

	noticiasModel.getNoticia(id_noticia, function(error, result){
         res.render("noticias/noticia", {noticia : result});

	});
}