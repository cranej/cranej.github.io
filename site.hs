--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid         (mappend)
import           Hakyll
import           Text.Pandoc.Options

--------------------------------------------------------------------------------
main :: IO ()
main = do
    let deployFile = "./deploy.sh"
    deployScripts <- readFile deployFile
    let config = myConfig {deployCommand = deployScripts }
    hakyllWith config $ do
        match "images/*" $ do
            route   idRoute
            compile copyFileCompiler

        match "css/*" $ do
            route   idRoute
            compile compressCssCompiler

        match (fromList ["CNAME", "key.asc"]) $ do
          route idRoute
          compile copyFileCompiler

        match (fromList ["about.markdown", "hstack.markdown"]) $ do
            route   $ setExtension "html"
            compile $ pandocCompilerWith mdOptions defaultHakyllWriterOptions
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls

        match "posts/*" $ do
            route $ setExtension "html"
            compile $ pandocCompilerWith mdOptions defaultHakyllWriterOptions
                >>= loadAndApplyTemplate "templates/post.html"    postCtx
                >>= loadAndApplyTemplate "templates/default.html" postCtx
                >>= relativizeUrls

        create ["archive.html"] $ do
            route idRoute
            compile $ do
                posts <- recentFirst =<< loadAll "posts/*"
                let archiveCtx =
                        listField "posts" postCtx (return posts) `mappend`
                        constField "title" "Archives"            `mappend`
                        defaultContext

                makeItem ""
                    >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                    >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                    >>= relativizeUrls


        match "index.html" $ do
            route idRoute
            compile $ do
                posts <- fmap (take 10) . recentFirst =<< loadAll "posts/*"
                let indexCtx =
                        listField "posts" postCtx (return posts) `mappend`
                        constField "title" "Home"                `mappend`
                        defaultContext

                getResourceBody
                    >>= applyAsTemplate indexCtx
                    >>= loadAndApplyTemplate "templates/default.html" indexCtx
                    >>= relativizeUrls

        match "templates/*" $ compile templateBodyCompiler


--------------------------------------------------------------------------------
-- TODO: read from external file
myConfig :: Configuration
myConfig = def

postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

mdOptions :: ReaderOptions
mdOptions = defaultHakyllReaderOptions {readerExtensions = githubMarkdownExtensions}
