# fp-jsonwebtoken

<p align="center">
  <img src="https://github.com/natanbueno/fp-jsonwebtoken/blob/main/img/basicdemo.png?raw=true" alt="FPJsonWebToken" />
</p>

## 🔑 O que é um JWT?
É um padrão especificado pela [RFC-7519](https://tools.ietf.org/html/rfc7519) que define como transmitir e armazenar [Objeto JSON](https://developer.mozilla.org/pt-BR/docs/Learn/JavaScript/Objects/JSON) de forma compacta e segura entre diferentes aplicações. As informações podem ser verificadas e confiadas porque elas possuem uma assinatura que é feita digitalmente por meio de uma criptografia HMAC utilizando uma chave secreta. 


## 💻 Sobre o projeto
fp-jsonwebtoken não é um <strong>[Framework, Componente]</strong>, é apenas um conjunto de bibliotecas para gerar, assinar e validar <strong>TOKENS JWT</strong> no <strong>free pascal</strong> ou <strong>lazarus</strong> como preferir chamar. 

## 🧪 Tecnologias
- [Lazarus-ide](https://www.lazarus-ide.org/)
- [Freepascal](https://www.freepascal.org/)
- [DCPcrypt](https://wiki.freepascal.org/DCPcrypt)

## ✨ Algoritmos para assinatura do <strong>compact token</strong>
| _Algorithms_ | _Supported_ | 
| -------------| ----------- |
|  `HS256`     | ✔️         |
|  `HS384`     | ❌         |
|  `HS512`     | ❌         |
|  `RS256`     | ❌         |
|  `RS384`     | ❌         |
|  `RS512`     | ❌         |
|  `ES256`     | ❌         |
|  `ES384`     | ❌         |
|  `ES512`     | ❌         |
|  `ES256K`    | ❌         |

<p align="center"><strong>Nota:</strong> Se deseja que a assinatura seja diferente HS256 é só abrir um <strong>Ussues<strong>. <strong>Pull Request<strong> também são bem vindos.<p>
  
## 🔖 Entenda o fluxo de um JSON Web Token
<img height="320" src="https://github.com/natanbueno/fp-jsonwebtoken/blob/main/img/fluxoJWT.png?raw=true" alt="Fluxo JSONWEBTOKEN" />
  
## 📒 Estrutura de pastas 
```shell
  ├── src
      └── fp.jwt.claims.pas
      └── fp.jwt.core.pas
      └── fp.jwt.core.pas
      └── fp.jwt.header.pas
      └── fp.jwt.pas
      └── fp.jwt.sign.pas
      └── fp.jwt.utils.pas
      └── fp.jwt.verify.pas
  ├── .gitignore
  ├── LICENSE
  ├── README.md
```
