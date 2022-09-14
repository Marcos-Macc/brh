/*Relatório de departamentos*/
select d.sigla, d.nome from brh.departamento d order by d.nome; 

/*Relatório de dependentes*/
select c.nome Colaborador, d.nome Dependente, to_date(d.data_nascimento, 'dd/mm/yyyy') nasc_DEP, d.parentesco from brh.colaborador c
inner join brh.dependente d on d.colaborador = c.matricula
order by c.nome, d.nome;


/*Inserir novo colaborador em projeto.*/
insert into brh.papel (nome) values ('Especialista de Negócios');
insert into brh.projeto (nome, responsavel, inicio, fim) VALUES ('BI', 'A123', to_date('25/08/2022', 'dd/mm/yyyy'), null);
insert into brh.colaborador (matricula,cpf,nome,email_pessoal,email_corporativo,salario,departamento,cep,complemento_endereco)
VALUES ('F124', '124.124.124-24','Fulano de Tal', 'fulano@email.com', 'fulano@email.com', 3000.00, 'DEPTI', '71222-300', 'Casa 1');
insert into brh.telefone_colaborador (numero,colaborador,tipo) VALUES ('(61) 9 9999-9999', 'F124', 'C');
insert into brh.atribuicao VALUES ('F124', (select id from brh.projeto where nome = 'BI'), (select id from brh.papel where nome = 'Especialista de Negócios'));


/*Excluir departamento SECAP*/
delete from brh.atribuicao where colaborador in (select matricula from brh.colaborador where departamento = 'SECAP');
delete from brh.telefone_colaborador where colaborador in (select matricula from brh.colaborador where departamento = 'SECAP');
delete from brh.projeto where responsavel in (select matricula from brh.colaborador where departamento = 'SECAP');
delete from brh.dependente where colaborador in (select matricula from brh.colaborador where departamento = 'SECAP');
update brh.departamento set chefe = 'F124' where chefe in (select matricula from brh.colaborador where departamento = 'SECAP');
delete from brh.colaborador where departamento = 'SECAP';
delete from brh.departamento where sigla = 'SECAP';

/*Relatório de contatos*/
select c.nome, c.email_corporativo, tel.numero
from brh.colaborador c
left join brh.telefone_colaborador tel on tel.colaborador = c.matricula
where tel.tipo <> 'R';

/*Relatório analítico de equipes*/
select dep.nome nomeDepartamento, c1.nome nomeChefeDepart, c.nome nomeColaborador,
pr.nome nomeProjeto, pa.nome nomePapel, tel.numero, depen.nome nomeDependente
from brh.departamento dep
inner join brh.colaborador c1 on c1.matricula = dep.chefe
inner join brh.colaborador c on c.departamento = dep.sigla
inner join brh.atribuicao atr on atr.colaborador = c.matricula
inner join brh.projeto pr on pr.id = atr.projeto
inner join brh.papel pa on pa.id = atr.papel
left join brh.dependente depen on depen.colaborador = c.matricula
left join brh.telefone_colaborador tel on tel.colaborador = c.matricula
order by dep.nome;
