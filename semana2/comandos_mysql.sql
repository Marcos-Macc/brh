/*Relatório de departamentos*/
select d.sigla, d.nome from departamento d order by d.nome; 

/*Relatório de dependentes*/
select c.nome Colaborador, d.nome Dependente, date_format(d.data_nascimento, "%d/%m/%Y") nasc_DEP, d.parentesco from colaborador c
inner join dependente d on d.colaborador = c.matricula
order by c.nome, d.nome;


/*Inserir novo colaborador em projeto.*/
insert into papel (nome) values ('Especialista de Negócios');
insert into projeto (nome, responsavel, inicio, fim) VALUES ('BI', 'A123', '2022-08-23', null);
insert into colaborador (matricula,cpf,nome,email_pessoal,email_corporativo,salario,departamento,cep,complemento_endereco)
VALUES ('F124', '124.124.124-24','Fulano de Tal', 'fulano@email.com', 'fulano@email.com', 3000.00, 'DEPTI', '71222-300', 'Casa 1');
insert into telefone_colaborador (numero,colaborador,tipo) VALUES ('(61) 9 9999-9999', 'F124', 'C');
insert into atribuicao VALUES ('F124', (select id from projeto where nome = 'BI'), (select id from papel where nome = 'Especialista de Negócios'));


/*Excluir departamento SECAP*/
delete from atribuicao where colaborador in (select matricula from colaborador where departamento = 'SECAP');
delete from telefone_colaborador where colaborador in (select matricula from colaborador where departamento = 'SECAP');
delete from projeto where responsavel in (select matricula from colaborador where departamento = 'SECAP');
delete from dependente where colaborador in (select matricula from colaborador where departamento = 'SECAP');
SET SQL_SAFE_UPDATES=0;
update  departamento set chefe = 'F124' where chefe in (select matricula from colaborador where departamento = 'SECAP');
SET SQL_SAFE_UPDATES=1;
delete from colaborador where departamento = 'SECAP';
delete from departamento where sigla = 'SECAP';
