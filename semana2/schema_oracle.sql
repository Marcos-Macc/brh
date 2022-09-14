alter session set "_ORACLE_SCRIPT" = true;

CREATE USER brh
    IDENTIFIED BY brh
    DEFAULT TABLESPACE users
    QUOTA UNLIMITED ON users;

create table brh.PAPEL(
    id integer not null,
    nome varchar2(100) not null,
    constraint pk_sigla primary key (id)
);

create table brh.CEPS(
    id_cep integer not null,
    cep varchar2(15) not null,
    logradouro varchar2(100) not null,
    bairro varchar2(100) not null,
    cidade varchar2(100) not null,
    estado varchar2(100) not null,
    constraint pk_ceps primary key (id_cep)
);

create table brh.PESSOA(
    cpf varchar2(15) not null,
    nome varchar2(100) not null,
    email_pessoal varchar2(10) not null,
    constraint pk_cpf primary key (cpf)
);

create table brh.DEPARTAMENTO(
    sigla VARCHAR2(10) not null,
    nome varchar2(100) not null,
    chefe integer not null,
    departamento_superior varchar2(10) not null,
    constraint pk_departamento_sigla primary key (sigla)
);

create table brh.COLABORADOR(
    matricula integer not null,
    cpf varchar2(15) not null,
    email_corporativo varchar2(100) not null,
    salario decimal (8,2) not null,
    complemento varchar2(30) not null,
    departamento varchar2(10) not null,
    id_cep integer not null,
    constraint pk_matricula primary key (matricula),
    constraint fk_colaborador_departamento
        foreign key (departamento)
        references brh.departamento (sigla),
    constraint fk_colaborador_ceps
        foreign key (id_cep)
        references brh.ceps (id_cep),
    constraint fk_colaborador_pessoa
        foreign key (cpf)
        references brh.pessoa (cpf)
);

create table brh.DEPENDENTE(
    cpf varchar2(15) not null,
    colaborador integer not null,
    nome varchar2(30) not null,
    data_nascmento date not null,
    parentesco varchar2(15) not null,
    constraint pk_dependente primary key (cpf,colaborador),
    constraint fk_dependente_colaborador
        foreign key (colaborador)
        references brh.colaborador (matricula)
);

create table brh.TELEFONES(
    matricula integer not null,
    telefone1 varchar2(16) not null,
    telefone2 varchar2(16) not null,
    constraint pk_telefones primary key (matricula),
    constraint fk_telefones_colaborador
        foreign key (matricula)
        references brh.colaborador (matricula)
);

create table brh.PROJETO(
    id integer not null,
    nome varchar2(100) not null,
    responsavel integer not null,
    inicio date not null,
    fim date not null,
    constraint pk_projeto primary key (id),
    constraint fk_projeto_colaborador
        foreign key (responsavel)
        references brh.colaborador (matricula)
);

create table brh.ATRIBUICAO(
    colaborador integer not null,
    projeto integer not null,
    papel integer not null,
    constraint pk_atribuicao primary key (colaborador,projeto,papel),
    constraint fk_atribuicao_colaborador
        foreign key (colaborador)
        references brh.colaborador (matricula),
    constraint fk_atribuicao_projeto
        foreign key (projeto)
        references brh.projeto (id),
    constraint fk_atribuicao_papel
        foreign key (papel)
        references brh.papel (id)
);

    alter table brh.departamento add
    constraint fk_departamento_colaborador
        foreign key (chefe)
        references brh.colaborador (matricula);
    alter table brh.departamento add 
    constraint fk_departamento_departamento_superior
        foreign key (departamento_superior)
        references brh.departamento (sigla);
