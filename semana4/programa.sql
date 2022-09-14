/*Criar procedure insere_projeto*
CREATE OR REPLACE PROCEDURE brh.INSERE_PROJETO 
(
  p_NOME_PROJETO IN brh.projeto.nome%TYPE, p_responsavel IN brh.projeto.responsavel%TYPE, p_dInicio IN brh.projeto.inicio%TYPE,
  p_dFIM brh.projeto.fim%TYPE
) IS 
    e_NOME_INVALIDO exception;
BEGIN
    if (length(p_nome_projeto)<2) or p_nome_projeto is null then
        raise e_NOME_INVALIDO;
    end if;
  INSERT INTO brh.PROJETO (NOME, RESPONSAVEL, INICIO, FIM) VALUES (p_nome_projeto, p_responsavel, p_dInicio, p_dFIM);
EXCEPTION
    WHEN e_NOME_INVALIDO THEN
        raise_application_error(-20001, 'Nome de projeto inválido! Deve ter dois ou mais caracteres.');
END INSERE_PROJETO;
/
/*Criar função calcula_idade*
CREATE OR REPLACE FUNCTION brh.calcula_idade ( p_data_nascimento IN DATE)
return NUMBER
IS
    v_idade NUMBER;
    e_DATA_INVALIDA exception;
BEGIN
    if (sysdate-p_data_nascimento) < 0 then
        raise e_DATA_INVALIDA;
    end if;
    v_idade :=  trunc(months_between(sysdate, p_data_nascimento)/12);
    RETURN v_idade;
EXCEPTION
    when e_DATA_INVALIDA then
        raise_application_error(-20002,'Impossível calcular idade! Data inválida: '||to_char(p_data_nascimento,'dd/mm/yyyy') || '.');
END calcula_idade;
/
/*Criar function finaliza_projeto*
CREATE OR REPLACE FUNCTION brh.finaliza_projeto (p_ID_projeto IN brh.projeto.ID%TYPE)
return DATE
IS
    e_PROJETO_ID_INEXISTENTE exception;
BEGIN
    UPDATE brh.projeto p set p.fim = sysdate where p.id = p_id_projeto;
    if SQL%NOTFOUND THEN
        RAISE e_PROJETO_ID_INEXISTENTE;
    END IF;
    return sysdate;
EXCEPTION
    WHEN e_PROJETO_ID_INEXISTENTE THEN
        raise_application_error(-20001, 'Projeto inexistente.');
END;
/
*/
/*Mover procedures e funções para package*/
CREATE OR REPLACE PACKAGE brh.PKG_PROJETO
IS
    PROCEDURE INSERE_PROJETO (  p_NOME_PROJETO IN brh.projeto.nome%TYPE, p_responsavel IN brh.projeto.responsavel%TYPE, p_dInicio IN brh.projeto.inicio%TYPE,
        p_dFIM brh.projeto.fim%TYPE);
    FUNCTION calcula_idade ( p_data_nascimento IN DATE) return NUMBER;
    FUNCTION finaliza_projeto (p_ID_projeto IN brh.projeto.ID%TYPE) return DATE;
    PROCEDURE define_atribuicao (nome_colaborador IN brh.colaborador.nome%TYPE, nome_projeto IN brh.projeto.nome%TYPE,
    nome_papel IN brh.papel.nome%TYPE);
END;

/





CREATE OR REPLACE PACKAGE BODY brh.PKG_PROJETO
IS
    PROCEDURE INSERE_PROJETO (  p_NOME_PROJETO IN brh.projeto.nome%TYPE, p_responsavel IN brh.projeto.responsavel%TYPE, p_dInicio IN brh.projeto.inicio%TYPE,
        p_dFIM brh.projeto.fim%TYPE) IS 
    e_NOME_INVALIDO exception;
BEGIN
    if (length(p_nome_projeto)<2) or p_nome_projeto is null then
        raise e_NOME_INVALIDO;
    end if;
  INSERT INTO brh.PROJETO (NOME, RESPONSAVEL, INICIO, FIM) VALUES (p_nome_projeto, p_responsavel, p_dInicio, p_dFIM);
EXCEPTION
    WHEN e_NOME_INVALIDO THEN
        raise_application_error(-20001, 'Nome de projeto inválido! Deve ter dois ou mais caracteres.');
END INSERE_PROJETO;

/*Criar função calcula_idade*/
FUNCTION calcula_idade ( p_data_nascimento IN DATE)
return NUMBER
IS
    v_idade NUMBER;
    e_DATA_INVALIDA exception;
BEGIN
    if (sysdate-p_data_nascimento) < 0 then
        raise e_DATA_INVALIDA;
    end if;
    v_idade :=  trunc(months_between(sysdate, p_data_nascimento)/12);
    RETURN v_idade;
EXCEPTION
    when e_DATA_INVALIDA then
        raise_application_error(-20002,'Impossível calcular idade! Data inválida: '||to_char(p_data_nascimento,'dd/mm/yyyy') || '.');
END calcula_idade;

/*Criar function finaliza_projeto*/
FUNCTION finaliza_projeto (p_ID_projeto IN brh.projeto.ID%TYPE)
return DATE
IS
    e_PROJETO_ID_INEXISTENTE exception;
BEGIN
    UPDATE brh.projeto p set p.fim = sysdate where p.id = p_id_projeto;
    if SQL%NOTFOUND THEN
        RAISE e_PROJETO_ID_INEXISTENTE;
    END IF;
    return sysdate;
EXCEPTION
    WHEN e_PROJETO_ID_INEXISTENTE THEN
        raise_application_error(-20001, 'Projeto inexistente.');
END;

PROCEDURE define_atribuicao (nome_colaborador IN brh.colaborador.nome%TYPE, nome_projeto IN brh.projeto.nome%TYPE,
    nome_papel IN brh.papel.nome%TYPE)
IS
    e_colaborador_invalido exception;
    e_projeto_invalido exception;
    e_papel_invalido exception;
    v_cColab brh.colaborador.matricula%TYPE;
    v_cProj brh.projeto.id%TYPE;
    v_cPapel brh.papel.id%TYPE;
BEGIN
    begin
    select c.matricula into v_cColab from brh.colaborador c where upper(c.nome) = upper(nome_colaborador);
    exception
    when no_data_found THEN
            raise e_colaborador_invalido;
    END;
    begin
    select pr.id into v_cProj from brh.projeto pr where upper(pr.nome) = upper(nome_projeto);
    exception
    when no_data_found THEN
            raise e_projeto_invalido;
    end;
    begin
    select p.id into v_cPapel from brh.papel p where upper(p.nome) = upper(nome_papel);
    EXCEPTION
    WHEN no_data_found THEN
        raise e_papel_invalido;
    end;
    
    INSERT INTO brh.atribuicao(colaborador, projeto, papel) VALUES (v_cColab, v_cProj, v_cPapel);
EXCEPTION
    WHEN e_colaborador_invalido THEN
        raise_application_error(-20001, 'Colaborador inexistente: '||nome_colaborador);
    WHEN e_projeto_invalido THEN
        raise_application_error(-20002, 'Projeto inexistente: '||nome_projeto);
    WHEN e_papel_invalido THEN
    begin
        INSERT INTO brh.papel p (nome) VALUES (nome_papel);
        select p.id into v_cPapel from brh.papel p where upper(p.nome) = upper(nome_papel);
        INSERT INTO brh.atribuicao(colaborador, projeto, papel) VALUES (v_cColab, v_cProj, v_cPapel);
    END;
  
END define_atribuicao;


END;


--    EXECUTE brh.DEPTREE_FILL('procedure', 'brh', 'INSERE_PROJETO');
--    SELECT NESTED_LEVEL, SCHEMA, TYPE, NAME FROM brh.DEPTREE ORDER BY SEQ#;