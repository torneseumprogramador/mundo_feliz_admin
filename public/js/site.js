
var mundofeliz ={}

mundofeliz.pagamentoBoleto = function(){
  var pg_id = "";

  Iugu.setTestMode(true);
  Iugu.setAccountID(pg_id);
  Iugu.setup();

  var cliente_id = $("#cliente_id").val();
  var cpf = $("#cpf").val();
  var telefone = $("#telefone").val();
  var email = $("#email").val();
  var cep = $("#cep").val();
  var endereco = $("#endereco").val();
  var numero = $("#numero").val();
  var bairro = $("#bairro").val();
  var cidade = $("#cidade").val();
  var estado = $("#estado").val();

  $.post("/cliente/concluir-pagamento", {
    cliente_id: cliente_id,
    cpf: cpf,
    telefone: telefone,
    email: email,
    cep: cep,
    endereco: endereco,
    numero: numero,
    bairro: bairro,
    cidade: cidade,
    estado: estado
  }).done(function() {
    window.location.href = '/cliente/seu-boleto'
  })
  .fail(function() {
    alert( "error" );
  });
}

mundofeliz.pagamentoCartao = function(){
  var pg_id = "0356A63D7B814C8CB330668A34A48CD6";

  Iugu.setTestMode(true);
  Iugu.setAccountID(pg_id);
  Iugu.setup();
  
  var number = $("#number").val()
  var mes = $("#mes").val()
  var ano = $("#ano").val()
  var nome = $("#nome").val()
  var sobrenome = $("#sobrenome").val()
  var cvv = $("#cvv").val()
  var cliente_id = $("#cliente_id").val()
  cc = Iugu.CreditCard(number, mes, ano, nome, sobrenome, cvv);

  Iugu.createPaymentToken(cc, function(data) {
    if (data.errors) {
      alert("erro ao gerar");
      console.log(data.errors);
    } else {
      var token = data.id;

      $.post("/cliente/concluir-pagamento", {token: token, cliente_id: cliente_id}).done(function() {
        window.location.href = '/cliente/compra-concluida'
      })
      .fail(function() {
        alert( "error" );
      });

    }
  });
}