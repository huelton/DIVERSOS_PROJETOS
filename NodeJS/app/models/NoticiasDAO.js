function NoticiasDAO(connection){

    this._connection = connection;
}
                               //usado na pagina Noticias
NoticiasDAO.prototype.getNoticias = function(callback){
	this._connection.query('SELECT * FROM noticias ORDER BY data_criacao DESC', callback);
}

                                //usado na pagina Noticia
NoticiasDAO.prototype.getNoticia = function(id_noticia, callback){
	this._connection.query('SELECT * FROM noticias WHERE id_noticia = ' + id_noticia.id_noticia, callback);
}

NoticiasDAO.prototype.salvarNoticia = function(noticia, callback){
    this._connection.query('INSERT INTO noticias SET ? ', noticia, callback);
}


NoticiasDAO.prototype.get5UltimasNoticias = function(callback){
	this._connection.query('SELECT * FROM noticias ORDER BY data_criacao DESC limit 5', callback);
}


module.exports = function() {
	
	return NoticiasDAO;

}