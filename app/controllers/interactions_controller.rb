class InteractionsController < ApplicationController
  def show
    @interaction = DataModel::Interaction.find(params[:id])
    @drug = @interaction.drug
    @gene = @interaction.gene
  end

  def interaction_search_results
    gene_names = params[:genes].split("\n").collect(&:strip)
    unless params[:geneFile].nil?
      gene_names.concat(params[:geneFile].read.split("\n")).collect(&:strip)
    end
    gene_names.delete_if(&:empty?)

    params[:gene_names] = gene_names

    search_results = LookupGenes.find(params)
    @search_results = InteractionSearchResultsPresenter.new(search_results, params)
  end
end
