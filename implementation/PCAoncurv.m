function score = PCAoncurv(datamatrix,varlabels,showflag)
%

if strcmp(showflag,'show')
    figure;
    boxplot(datamatrix,'orientation','horizontal','labels',varlabels);
end


C = corr(datamatrix,datamatrix);
fprintf('Correlation Matrix:\n');
display(C);

%{
w = 1./var(datamatrix);
[wcoeff,score,latent,tsquared,explained] = pca(datamatrix,'VariableWeights',w);
coefforth = diag(sqrt(w))*wcoeff;
%}
[wcoeff,score,sd2,~,explained] = pca(datamatrix,'VariableWeights','variance');
coefforth = diag(std(datamatrix))\wcoeff;


if strcmp(showflag,'show')
    figure;
    pareto(explained);
    xlabel('Principal Component');
    ylabel('Variance Explained (%)');
end


if strcmp(showflag,'show')
    figure;
    subplot(2,2,1)
    plot3(score(:,1),score(:,2),score(:,3),'+')
    grid on
    xlabel('1st PC')
    ylabel('2nd PC')
    zlabel('3rd PC')    
    set(gca,'FontSize',6)
    subplot(2,2,2)
    plot(score(:,1),score(:,2),'+')
    grid off
    xlabel('1st PC')
    ylabel('2nd PC')
    set(gca,'FontSize',6)
    subplot(2,2,3)
    plot(score(:,1),score(:,3),'+')
    grid off
    xlabel('1st PC')
    ylabel('3rd PC')
    set(gca,'FontSize',6)
    subplot(2,2,4)
    plot(score(:,2),score(:,3),'+')
    grid off
    xlabel('2nd PC')
    ylabel('3rd PC')
    set(gca,'FontSize',6)
end



fprintf('Variance of Components:\n');
display(sd2);


%{
if strcmp(showflag,'show')
    figure;
    biplot(coefforth(:,1:3),'scores',score(:,1:3),'varlabels',varlabels);
    %axis([-.26 0.6 -.51 .51]);
end
%}
