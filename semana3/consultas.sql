/*FILTRAR DEPENDENTES*/
select c.nome nomeColaborador, d.nome nomeDependente, d.data_nascimento
from brh.dependente d
inner join brh.colaborador c on c.matricula= d.colaborador
where to_number(to_char(d.data_nascimento, 'mm')) between 4 and 6
or instr(lower(d.nome), 'h') > 0
order by c.nome, d.nome;

/*LISTAR COLABORADOR COM MAIOR SALÁRIO*/
select colab.nome, colab.salario
from brh.colaborador colab
where colab.salario = (select max(c1.salario) from brh.colaborador c1);

/*RELATÓRIO DE SENIORIDADE*/
select c.matricula, c.nome, c.salario,
case when c.salario <=3000 then 'Júnior'
when c.salario between 3000.01 and 6000 then 'Pleno'
when c.salario between 6000.01 and 20000 then 'Sênior'
else 'Corpo diretor' end Senioridade
from brh.colaborador c
order by senioridade, c.nome;

/*LISTAR COLABORADORES EM PROJETOS*/
select dep.nome Departamento, proj.nome Projeto, count(c.matricula) Qtde_colaboradores
from brh.departamento dep
inner join brh.colaborador c on c.departamento = dep.sigla
inner join brh.atribuicao a on a.colaborador = c.matricula
inner join brh.projeto proj on proj.id = a.projeto
group by dep.nome, proj.nome
order by dep.nome, proj.nome;

/*LISTAR COLABORADORES COM MAIS DEPENDENTES*/
CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "BRH"."QTDE_DEPEN_COLAB" ("COLABORADOR", "QTDE_DEPENDENTES") AS 
  select c.nome Colaborador, count(d.colaborador) Qtde_dependentes
from brh.colaborador c
inner join brh.dependente d on d.colaborador = c.matricula
group by c.nome;
select t.Colaborador, t.Qtde_dependentes from
brh.qtde_depen_colab t
where  t.Qtde_dependentes>1
order by t.Qtde_dependentes desc, t.Colaborador;

/*LISTAR FAIXA ETÁRIA DOS DEPENDENTES*/
select dep.cpf, dep.nome, to_char(dep.data_nascimento, 'dd/mm/yyyy') nascimento, dep.parentesco,
c.matricula "MATRÍCULA COLABORADOR", trunc(months_between(sysdate, dep.data_nascimento)/12) idade, 
case when trunc(months_between(sysdate, dep.data_nascimento)/12) <18 then 'Menor de idade'
else 'Maior de idade' END "FAIXA ETÁRIA"
from brh.dependente dep
inner join brh.colaborador c on c.matricula = dep.colaborador
order by c.matricula, dep.nome;

/*RELATÓRIO DE PLANO DE SAÚDE*/
CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "BRH"."CONTRIBUICAO_COLABORADOR" ("MATRICULA", "SALARIO", "SENIORIDADE", "CONTRIBUICAO") AS 
  select c.matricula, c.salario,
case when c.salario <=3000 then 'Júnior'
when c.salario between 3000.01 and 6000 then 'Pleno'
when c.salario between 6000.01 and 20000 then 'Sênior'
else 'Corpo diretor' end Senioridade,
case when c.salario <=3000 then 0.01
when c.salario between 3000.01 and 6000 then 0.02
when c.salario between 6000.01 and 20000 then 0.03
else 0.05 end contribuicao
from brh.colaborador c;

  CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "BRH"."CONTRIBUICAO_DEPENDENTE" ("CPF", "NOME", "COLABORADOR", "DATA_NASCIMENTO", "PARENTESCO", "IDADE", "FAIXA_ETARIA", "CONTRIBUICAO") AS 
  select d.cpf, d.nome, d.colaborador, d.data_nascimento, d.parentesco, trunc(months_between(sysdate, d.data_nascimento)/12) idade,
case when trunc(months_between(sysdate, d.data_nascimento)/12) <18 then 'Menor de idade'
else 'Maior de idade' END faixa_etaria,
case when d.parentesco like '%njuge' then 100.00
when trunc(months_between(sysdate, d.data_nascimento)/12) >18 then 50.00
else 25.00 END contribuicao
from brh.dependente d;

select c.matricula, c.nome, c.salario, (c.salario*cc.contribuicao+sum(cd.contribuicao)) mensalidade
from brh.colaborador c
inner join brh.contribuicao_colaborador cc on cc.matricula = c.matricula
inner join brh.contribuicao_dependente cd on cd.colaborador = c.matricula
group by c.matricula, c.nome, c.salario, cc.contribuicao
order by c.nome;

/*PAGINAR LISTAGEM DE COLABORADORES*/
select * from (select rownum linha, c.nome
from brh.colaborador c
order by c.nome) l
where l.linha between 11 and 20;


/*LISTAR COLABORADORES QUE PARTICIPARAM DE TODOS OS PROJETOS*/
select a.colaborador matricula, c.nome
from brh.atribuicao a
inner join brh.colaborador c on c.matricula = a.colaborador
where a.projeto in (
select id from brh.projeto)
group by a.colaborador, c.nome
having count(*) = (select count(*) from brh.projeto);