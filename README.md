# Gratuité: Formulaire d'inscription

Formulaire d'inscription pour la Gratuité

## Requis

Pour installer ce projet il faut disposer des outils suivant:

 * Git
 * Docker (en mode swarm)

## Installation

1 - Clone avec Git ce projet
```shell
$ git clone git@github.com:Dieek26/gratuite-inscription.git
```

2 - Placez vous dans le dosssier nouvellement cloné
```shell
$ cd gratuite-inscription
```

3 - Activez le mode swarm de docker _(Si vous ne l'avez pas déjà activé)_
```shell
$ docker swarm init
```

4 - Démarrez la stack traefk _(Uniquement la première fois)_
```shell
$ docker stack deploy -c .docker/docker-compose-traefik.yaml traefik
```
