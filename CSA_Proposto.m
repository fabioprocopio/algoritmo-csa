function convergencia = CSA_Proposto(pd, N, tmax, funcao)  


% AP       = 0.1;  % Probabilidade de consci�ncia
% fl       = 2;    % Tempo do voo


% VALORES PRESENTES NO PAPER DO CPO
AP       = 0.05;  
fl       = 1.5; 





[l, u] = get_espaco_busca(funcao);
funcao = str2func(funcao);

% Fun��o para inicializa��o da popula��o
[x l u] = inicializa_bando(N, pd, l, u);
x = enquadra_espaco_busca(x, l, u);

xn = x;
for i=1:N
  ft(i) = funcao(xn(i, :));
end 

mem     = x;  % Inicializa mem�ria
fit_mem = ft; % Fitness of memory positions

ngbest = find(fit_mem == min(fit_mem));
melhor_sol = mem(ngbest(1),:);

convergencia = [];
for t=1:tmax
    seguidor = ceil(N*rand(1,N)); % Generation of random candidate crows for following (chasing)
    for i=1:N
        % Amea�a n�o identificada ==> Intensifica��o            
        if rand > AP 
            xnew(i,:) = x(i,:) + fl * rand * (mem(seguidor(i),:)-x(i,:));
            xnew(i,:) = EOBL(melhor_sol, xnew(i, :));
        else % Amea�a identificada ==> Diversifica��o
            xnew(i,:) = GOBL(x(i,:), l, u);
        end            
    end

    xnew = enquadra_espaco_busca(xnew, l, u); 
    xn = xnew;

    for i=1:N
        % Avalia a fun��o objetivo das novas posi��es
        ft(i) = funcao(xn(i, :));
    end 

    % Atualiza posi��o e mem�ria    
    for i=1:N
        if xnew(i,:)>=l & xnew(i,:)<=u
            x(i,:)=xnew(i,:);           % Posi��o
            if ft(i) < fit_mem(i)
                mem(i,:)   = xnew(i,:); % Mem�ria
                fit_mem(i) = ft(i);
            end
        end
    end

    % Melhor valor de fitness at� o momento
    ffit(t) = min(fit_mem);
    convergencia = [convergencia ffit(t)];

    ngbest = find(fit_mem == ffit(t));
    melhor_sol = mem(ngbest(1),:);
end
ngbest = find(fit_mem == min(fit_mem));
g_best = mem(ngbest(1),:);
melhor_fitness = min(fit_mem);

end

function [x l u] = inicializa_bando(N, pd, l, u) % Function for initialization
    for i=1:N % Generation of initial solutions (position of crows)
        for j=1:pd
            x(i,j)=l-(l-u)*rand; % Position of the crows in the space
        end
    end
end

function s = enquadra_espaco_busca(s, l, u)
  ns_tmp = s;

  % Verifica dimens�es fora do limite inferior
  I = ns_tmp < l;
  % Reposiciona dimens�es dentro do limite inferior
  ns_tmp(I) = l;

  % Verifica dimens�es fora do limite superior
  J = ns_tmp > u;
  % Reposiciona dimens�es dentro do limite superior
  ns_tmp(J) = u;

  % Atualiza as novas posi��es
  s = ns_tmp;
end